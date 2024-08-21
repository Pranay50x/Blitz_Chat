import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/alert_services.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/widgets/chat_file.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GetIt getIt = GetIt.instance; 

  late AuthService _authService;
  late NavigationService _navigationService; 
  late AlertServices _alertServices; 
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _navigationService = getIt.get<NavigationService>();
    _alertServices = getIt.get<AlertServices>(); 
    _databaseService = getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
            Tooltip(
              message: "Logout",
              child: IconButton(
                onPressed: () async{
                  bool result  = await _authService.logout(); 
                  if(result){
                    _alertServices.showToast(text: "Successfully Logged Out!", icon: Icons.check);  
                    _navigationService.pushReplacementNamed("/login");
                  }
                },
                icon: const Icon(Icons.logout),
              ),
            ),
        ],
      ),  
      backgroundColor: Colors.black,
      body: _buildUI(),
    );
  }

  Widget _buildUI(){
    return SafeArea(child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: _chatList(),
    ));
  }

  Widget _chatList(){
    return StreamBuilder(stream: _databaseService.getUserPrfile(), builder: (context, snapshot){
        if(snapshot.hasError){
          return const Center(
            child: Text("Unable to Load Data"),
          );
        }
        print(snapshot.data);   
        if(snapshot.hasData && snapshot.data!=null){
          final users = snapshot.data!.docs;
          return ListView.builder( itemCount: users.length ,
            itemBuilder: (context, index){
              UserProfile user = users[index].data();
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0
                ),
                child: ChatTile(userProfile: user, 
                onTap: () async {
                    final chatExists = await _databaseService.checkChatExists(_authService.user!.uid, user.uid!);
                if(!chatExists){
                  await _databaseService.createNewChat(_authService.user!.uid, user.uid!);
                }
                _navigationService.push(MaterialPageRoute(builder: (context) {
                  return ChatPage(chatUser: user,);
                }));
                }),
              );
          });
        }
        return const Center(
          child: CircularProgressIndicator(),    
        );
    }); 
  }
}