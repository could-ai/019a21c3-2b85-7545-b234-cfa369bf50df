import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: MaterialApp(
        title: 'WhatsApp Clone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF075E54),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF075E54),
            secondary: const Color(0xFF25D366),
          ),
        ),
        home: const HomePage(),
        routes: {
          '/chat': (context) => const ChatScreen(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return ListView.builder(
            itemCount: chatProvider.chats.length,
            itemBuilder: (context, index) {
              final chat = chatProvider.chats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Text(chat.name[0].toUpperCase()),
                ),
                title: Text(chat.name),
                subtitle: Text(chat.lastMessage),
                trailing: Text(chat.time),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/chat',
                    arguments: chat,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.message),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chat = ModalRoute.of(context)!.settings.arguments as Chat;
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(chat.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final message = chat.messages[chat.messages.length - 1 - index];
                return Align(
                  alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: message.isMe ? Colors.green : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message.text),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      chatProvider.addMessage(chat, _controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Chat {
  final String name;
  final List<Message> messages;
  String lastMessage;
  String time;

  Chat({
    required this.name,
    required this.messages,
    required this.lastMessage,
    required this.time,
  });
}

class Message {
  final String text;
  final bool isMe;

  Message({required this.text, required this.isMe});
}

class ChatProvider extends ChangeNotifier {
  List<Chat> chats = [
    Chat(
      name: 'Alice',
      messages: [
        Message(text: 'Hello!', isMe: false),
        Message(text: 'Hi there!', isMe: true),
      ],
      lastMessage: 'Hi there!',
      time: '10:30 AM',
    ),
    Chat(
      name: 'Bob',
      messages: [
        Message(text: 'Hey!', isMe: false),
      ],
      lastMessage: 'Hey!',
      time: '9:45 AM',
    ),
  ];

  void addMessage(Chat chat, String text) {
    chat.messages.add(Message(text: text, isMe: true));
    chat.lastMessage = text;
    chat.time = DateTime.now().toString().substring(11, 16);
    notifyListeners();
  }
}
