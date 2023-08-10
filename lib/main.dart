import 'package:bubble/bubble.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.yellowAccent,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Mon chat bot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<CustomMessage> customMessages = [];
  TextEditingController textEditingController = TextEditingController();
  DialogAuthCredentials? credentials;
  DialogFlowtter? dialogFlowtter;
  ScrollController? scrollController = ScrollController();

  bool isWritting = false;

  bool run = true;
  Path path_0 = Path();

  sendMessage(String text) async {
    addMessageToList(text, typeUser.currentUser);
    final responseBot = await getResponseToBot(text);
    if (responseBot != null) {
      addMessageToList(responseBot, typeUser.bot);
    }
  }

  addMessageToList(String text, typeUser typeuser) {
    final customMessage = CustomMessage(message: text, typeuser: typeuser);
    setState(() {
      customMessages.add(customMessage);
    });
    try {
      scrollController?.animateTo(
          scrollController!.position.maxScrollExtent + 70,
          duration: const Duration(milliseconds: 20),
          curve: Curves.linear);
    } catch (e) {
      print(e);
    }
  }

  Future<String?> getResponseToBot(String msg) async {
    setState(() {
      isWritting = true;
    });
    DetectIntentResponse response = await dialogFlowtter!.detectIntent(
        queryInput: QueryInput(
          text: TextInput(
            text: msg,
            languageCode: 'fr',
          ),
        ),
        audioConfig: OutputAudioConfig());

    String? textResponse = response.text;
    print(textResponse);
    setState(() {
      isWritting = false;
    });
    return textResponse;
  }

  @override
  void initState() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      credentials =
          await DialogAuthCredentials.fromFile('your_json_file_key.json');
      dialogFlowtter = DialogFlowtter(
        credentials: credentials!,
        sessionId: "generate_uid_random_for_id_conersation",
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade400,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(.7),
              ),
              child: LottieBuilder.asset('assets/animation_ll4zpkhi.json'),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 150,
              child: isWritting
                  ? const Text(
                      "En train d'ecrire ...",
                      style: TextStyle(fontSize: 18),
                    )
                  : Text(
                      widget.title,
                      style: const TextStyle(fontSize: 18),
                    ),
            )
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: customMessages.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              // color:
                              //     Theme.of(context).primaryColor.withOpacity(.7),
                            ),
                            child: LottieBuilder.asset(
                                'assets/animation_ll4zpkhi.json'),
                          ),
                          const Text(
                            'Bienvenue 🤗',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const Text(
                            'Vous pouvez commencer à chatter avec moi!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: customMessages.length,
                      controller: scrollController,
                      itemBuilder: (context, index) {
                        final message = customMessages[index];
                        return Row(
                          mainAxisAlignment: message.typeuser == typeUser.bot
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 250),
                              child: Bubble(
                                margin: const BubbleEdges.only(top: 10),
                                nip: message.typeuser == typeUser.bot
                                    ? BubbleNip.leftTop
                                    : BubbleNip.rightTop,
                                color: message.typeuser == typeUser.bot
                                    ? Colors.white
                                    : Colors.yellowAccent.withOpacity(.4),
                                child: Text(
                                  message.message ?? '',
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            Container(
              height: 60,
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.yellow.shade200,
                        ),
                        child: TextFormField(
                          controller: textEditingController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Entrer votre message...',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    elevation: 5,
                    onPressed: () {
                      final text = textEditingController.text.trim();
                      if (textEditingController.text.trim().isNotEmpty) {
                        sendMessage(text);
                        textEditingController.clear();
                      }
                    },
                    child: const Icon(
                      Icons.send,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomMessage {
  final String? message;
  final typeUser? typeuser;

  CustomMessage({this.message, this.typeuser});
}

enum typeUser { bot, currentUser }
