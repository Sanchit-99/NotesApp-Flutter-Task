import 'package:flutter/material.dart';
import 'package:notesapp/models/note_model.dart';
import 'package:notesapp/providers/note_provider.dart';
import 'package:notesapp/screens/login.dart';
import 'package:notesapp/screens/note_screen.dart';
import 'package:notesapp/services/auth.dart';
import 'package:notesapp/utilities.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    Provider.of<NoteProvider>(context, listen: false)
        .fetchNotes()
        .then((value) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final height = mq.size.height;
    final width = mq.size.width;
    final statusBarHeight = mq.padding.top;
    return Scaffold(
      key: _key,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.only(top: statusBarHeight),
          children: [
            ListTile(
              title: const Text('Sign Out'),
              onTap: () {
                AuthService().signOut(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //to notes screen with no values i.e create
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NoteScreen()));
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? showLoader()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    margin: EdgeInsets.only(top: mq.padding.top),
                    width: width,
                    height: height * 0.12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            _key.currentState!.openDrawer();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7)),
                              color: Color(0xfff3f4fe),
                            ),
                            height: 40,
                            width: 40,
                            child: Icon(
                              Icons.menu,
                              size: 20,
                            ),
                          ),
                        ),
                        Text(
                          'MyNotes',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 25,
                              fontWeight: FontWeight.w500),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(7)),
                            color: Color(0xfff3f4fe),
                          ),
                          height: 40,
                          width: 40,
                          child: Icon(
                            Icons.search,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: Consumer<NoteProvider>(
                  builder: (context, value, child) {
                    List<Note> notes = value.getItems;
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            confirmDismiss: (_) {
                              return showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Are you sure?'),
                                  content:
                                      Text('Do you want to delete this note?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Text('Yes'),
                                    )
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) {
                              Provider.of<NoteProvider>(context, listen: false)
                                  .deleteNote(notes[index].id!);
                            },
                            key: ValueKey(notes[index].id),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NoteScreen(note: notes[index])));
                              },
                              child: notesCard(
                                  context: context,
                                  height: height,
                                  width: width,
                                  date: parseDateTime(notes[index].date!),
                                  isFav: notes[index].isFav!,
                                  subTitle: notes[index].content!,
                                  title: notes[index].title!),
                            ),
                          );
                        });
                  },
                ))
              ],
            ),
    );
  }
}
