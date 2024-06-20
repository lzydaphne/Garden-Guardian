import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatInformDialog extends StatefulWidget {
  const ChatInformDialog({Key? key}) : super(key: key);

  @override
  _ChatInformDialogState createState() => _ChatInformDialogState();
}

class _ChatInformDialogState extends State<ChatInformDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: Colors.black54,
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: MarkdownBody(
                        data: """
## ChatBot Service Documentation

### Overview

The ChatBot is designed to interact with users and provide responses based on user inputs. It leverages the OpenAI GPT-4 model to generate responses and can handle various functionalities, including image processing, storing nicknames, counting goals, and finding similar messages.

### Features

1. **Text and Image Processing**:
   - The ChatBot can process both text and images. If an image URL is provided, it converts the image to a base64 string and includes it in the message content.
   
2. **Tool Calls**:
   - The ChatBot can call specific tools/functions based on the user's input and the context of the conversation. These tools can perform various tasks such as adding new plants, storing nicknames, and counting goals.

3. **Keyword Extraction**:
   - The ChatBot can extract keywords from user messages and use them to enhance the understanding and processing of the conversation.

4. **Response Generation**:
   - The ChatBot generates responses using the OpenAI GPT-4 model, ensuring high-quality and contextually relevant replies.

5. **Memory and Database Integration**:
   - The ChatBot maintains a history of messages and can retrieve similar past conversations to provide more relevant responses. It also updates the message database with new interactions and responses.

### Services and Functionalities

#### 1. **Image Processing**

- **Convert Image to Base64**: 
  - The `convertImageToBase64` method converts an image from a given URL to a base64 string for easy embedding in messages.

- **Read Image as Bytes**: 
  - The `readImageAsBytes` method reads the image data from the provided URL and returns it as bytes.

#### 2. **Tool Functions**

- **Add New Plant**:
  - The `addNewPlant` function adds a new plant with specified species, image, and care cycles (watering, fertilization, pruning).

- **Store Nickname**:
  - The `storeNickname` function stores a user's nickname in the database.

- **Counting Goal**:
  - The `counting_goal` function calculates goals related to plant care based on the user's input and care cycles.

- **Find Similar Messages**:
  - The `findSimilarMessage` function retrieves past messages similar to the current user query from the message database.

### Example Usage

#### Adding a New Plant

When a user provides an image URL and details about a new plant species, the ChatBot can process the image, store it, and add the plant to the user's plant list. This involves converting the image to base64, calling the `addNewPlant` function, and updating the message database with the response.
                        ],"""
                      )
                    ),

                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
