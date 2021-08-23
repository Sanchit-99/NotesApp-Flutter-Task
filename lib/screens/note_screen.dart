import 'package:flutter/material.dart';
import 'package:notesapp/models/note_model.dart';
import 'package:notesapp/providers/note_provider.dart';
import 'package:notesapp/utilities.dart';
import 'package:provider/provider.dart';

class NoteScreen extends StatefulWidget {
  final Note? note;
  NoteScreen({this.note});
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  bool isLoading = false;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    if (widget.note != null) {
      _titleController.text = widget.note!.title!;
      _contentController.text = widget.note!.content!;
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final height = mq.size.height;
    final width = mq.size.width;
    final statusBarHeight = mq.padding.top;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: isLoading
          ? showLoader()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    margin: EdgeInsets.only(top: statusBarHeight),
                    width: width,
                    height: (height - statusBarHeight) * 0.12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
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
                              Icons.arrow_back_ios_new,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    color: Color(0xfff3f4fe),
                  ),
                  width: width,
                  height: (height - statusBarHeight) * 0.8,
                  child: Stack(children: [
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FloatingActionButton(
                            child: Icon(Icons.save),
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                              });
                              if (widget.note != null) {
                                //edit

                                Provider.of<NoteProvider>(context,
                                        listen: false)
                                    .editNote(Note(
                                        id: widget.note!.id,
                                        content: _contentController.text,
                                        isFav: widget.note!.isFav,
                                        title: _titleController.text,
                                        date: widget.note!.date))
                                    .then((value) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              } else {
                                //new
                                Provider.of<NoteProvider>(context,
                                        listen: false)
                                    .createNote(Note(
                                        content: _contentController.text,
                                        isFav: false,
                                        title: _titleController.text,
                                        date: DateTime.now()))
                                    .then((value) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              }
                            },
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 20),
                          child: TextFormField(
                            controller: _titleController,
                            decoration: new InputDecoration(
                                border: InputBorder.none, hintText: 'Title'),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: TextFormField(
                            controller: _contentController,
                            decoration: new InputDecoration(
                                border: InputBorder.none, hintText: 'Content'),
                            maxLines: 15,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                Text(
                                    widget.note == null
                                        ? parseDateTime(DateTime.now())
                                        : parseDateTime(widget.note!.date!),
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300)),
                                Spacer(),
                                Icon(
                                  Icons.crop_original,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.mic,
                                  color: Colors.grey,
                                )
                              ],
                            )),
                      ],
                    ),
                  ]),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffeaedfa),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  width: width,
                  height: (height - statusBarHeight) * 0.08,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        'assets/pencil.png',
                        height: 25,
                        width: 25,
                      ),
                      widget.note == null
                          ? Icon(
                              Icons.star_border,
                              size: 35,
                              color: Colors.black,
                            )
                          : Consumer<NoteProvider>(
                              builder: (context, value, child) {
                              bool isFav = value.isFavorite(widget.note!.id!);
                              return InkWell(
                                onTap: () {
                                  Provider.of<NoteProvider>(context,
                                          listen: false)
                                      .toggleFavorite(widget.note!);
                                },
                                child: Icon(
                                  isFav ? Icons.star : Icons.star_border,
                                  size: 25,
                                  color:
                                      isFav ? Color(0xfff1a005) : Colors.black,
                                ),
                              );
                            }),
                      Image.asset(
                        'assets/share.png',
                        height: 25,
                        width: 25,
                      ),
                      Icon(
                        Icons.more_vert,
                        size: 25,
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
