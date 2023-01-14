import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

//Salar Dev
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salar Dev Chat GPT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController textController = TextEditingController();
  List messages = [];
  ChatGPT? chatGPT;
  StreamSubscription? _streamSubscription;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    chatGPT = ChatGPT.instance;
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription?.cancel();
  }

  void userMessage(String message) {
    setState(() {
      messages.insert(0, {'sender': 'user', 'message': message});
    });
    gptMessage(message);
    textController.clear();
  }

  void gptMessage(String message) {
    setState(() {
      isTyping = true;
    });
    final request =
        CompleteReq(prompt: message, model: kTranslateModelV3, max_tokens: 200);
    _streamSubscription = chatGPT!
        .builder("your-api-key", orgId: "")
        .onCompleteStream(request: request)
        .listen((response) {
      setState(() {
        isTyping = false;
        messages
            .insert(0, {'sender': 'gpt', 'message': response?.choices[0].text});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Salar Dev - Chat GPT',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            color: Colors.grey.withOpacity(0.3),
            child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: messages[index]['sender'] == 'user'
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          color: messages[index]['sender'] == 'user'
                              ? Colors.black
                              : Colors.grey.withOpacity(0.5),
                          child: Text(
                            messages[index]['message'],
                            style: TextStyle(
                              color: messages[index]['sender'] == 'user'
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          )),
          Container(
            padding: const EdgeInsets.all(10),
            height: 60,
            width: width,
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: textController,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  decoration: const InputDecoration.collapsed(
                      hintText: 'اكتب رسالتك',
                      hintStyle: TextStyle(
                        fontSize: 20,
                      )),
                )),
                isTyping
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      )
                    : IconButton(
                        onPressed: () {
                          userMessage(textController.text);
                        },
                        icon: const Icon(Icons.send),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
