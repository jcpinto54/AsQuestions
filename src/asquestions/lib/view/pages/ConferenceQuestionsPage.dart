import 'package:asquestions/view/pages/QuestionPage.dart';
import 'package:asquestions/view/pages/AddQuestionPage.dart';
import 'package:flutter/material.dart';
import 'package:asquestions/controller/CloudFirestoreController.dart';
import 'package:intl/intl.dart';
import '../../model/Question.dart';
import '../../view/widgets/CustomListView.dart';

class ConferenceQuestionsPage extends StatefulWidget {
  final CloudFirestoreController _firestore;

  ConferenceQuestionsPage(this._firestore);

  @override
  _ConferenceQuestionsState createState() => _ConferenceQuestionsState();
}

class _ConferenceQuestionsState extends State<ConferenceQuestionsPage> {
  List<Question> questions = new List();
  bool showLoadingIndicator = false;
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    this.refreshModel(true);
  }

  Future<void> refreshModel(bool showIndicator) async {
    Stopwatch sw = Stopwatch()..start();
    setState(() {
      showLoadingIndicator = showIndicator;
    });
    questions = await widget._firestore.getQuestions();
    if (this.mounted)
      setState(() {
        showLoadingIndicator = false;
      });
    print("Question fetch time: " + sw.elapsed.toString());
  }

  void _toggleUpvote(Question question) {
    setState(() {
      question.triggerUpvote();
    });
  }

  void _toggleDownvote(Question question) {
    setState(() {
      question.triggerDownvote();
    });
  }

  void openPage() {}

  @override
  Widget build(BuildContext context) {
    questions.sort((a, b) => b.votes.compareTo(a.votes));
    return Scaffold(
      appBar: AppBar(
        title: Text('Talk Questions'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_sharp),
            iconSize: 28,
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                    AddQuestionPage(widget._firestore)));
            }
          )
        ],
      ),
      body: Column(
        children: [
          Visibility(visible: showLoadingIndicator, child: LinearProgressIndicator()),
          Expanded(
            child: CustomListView(
            onRefresh: () => refreshModel(false),
            controller: scrollController,
            itemCount: questions.length,
            itemBuilder: (BuildContext context, int index) =>
                buildQuestionCard(context, index)),
          ),
        ],
      ),
    );
  }

  Widget buildQuestionCard(BuildContext context, int index) {
    final question = questions[index];
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => QuestionPage(widget._firestore, question.reference)));
      },
      child: Container(
        padding: const EdgeInsets.all(2.0),
        child: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image(image: AssetImage(question.user.picture))),
              ),
              buildCard(question),
              buildVotes(question),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(Question question) {
    final f = new DateFormat('dd-MM-yyy HH:mm');

    return Flexible(
      child: Padding(
        padding: EdgeInsets.only(left: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.title, style: new TextStyle(fontSize: 20.0)),
            Text(question.user.name, style: new TextStyle(fontSize: 15.0)),
            Container(
              height: 10,
            ),
            Divider(
                height: 0,
                thickness: 3,
                color: Colors.blue.shade200,
                indent: 0,
                endIndent: 40),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(f.format(question.date),
                  style: new TextStyle(fontSize: 12.0)),
            ),
            Text(question.comments.length.toString() + " comments",
                style: new TextStyle(fontSize: 12.0)),
          ],
        ),
      ),
    );
  }

  Widget buildVotes(Question question) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: Column(
        children: <Widget>[
          Transform.scale(
            scale: 2.0,
            child: IconButton(
                icon: Icon(Icons.keyboard_arrow_up_outlined),
                color: (question.voted == 1 ? Colors.green : Colors.black),
                onPressed: () {
                  _toggleUpvote(question);
                }),
          ),
          Text((question.votes).toString(),
              style: new TextStyle(fontSize: 18.0)),
          Transform.scale(
            scale: 2.0,
            child: IconButton(
                icon: Icon(Icons.keyboard_arrow_down_outlined),
                color: (question.voted == 2 ? Colors.red : Colors.black),
                onPressed: () {
                  _toggleDownvote(question);
                }),
          ),
        ],
      ),
    );
  }
}
