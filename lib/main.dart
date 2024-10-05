import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

void main() => runApp(const Assignment1());

class Post {
  final int id;
  final String updatedDate;
  final String location;
  final String type;
  final String site;
  final String companyName;
  final String companyLogo;
  final String jobRole;

  Post({
    required this.id,
    required this.updatedDate,
    required this.location,
    required this.type,
    required this.site,
    required this.companyName,
    required this.companyLogo,
    required this.jobRole,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final jobData = json['job'] as Map<String, dynamic>;

    return Post(
      id: jobData['id'] as int,
      updatedDate: jobData['created_date']
          as String, //Here I used created_date instead of updated_date because that was the same for both entries so it working wasn't apparent. but updated date also works here especially because to get the minutes ago time it should have minutes which created date ofcourse doesnt have.
      location: jobData['location']['name_en'] as String,
      type: jobData['type']['name_en'] as String,
      site: jobData['workplace_preference']['name_en'] as String,
      companyName: jobData['company']['name'] as String,
      companyLogo: jobData['company']['logo'] as String,
      jobRole: jobData['icp_answers']['job-role'][0]['title_en'] as String,
    );
  }
}

class Assignment1 extends StatelessWidget {
  const Assignment1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const JobHome(),
    );
  }
}

class JobHome extends StatefulWidget {
  const JobHome({super.key});

  @override
  State<JobHome> createState() => _JobHomeState();
}

class _JobHomeState extends State<JobHome> {
  Future<List<Post>> fetchAllPosts() async {
    final response = await http
        .get(Uri.parse('https://mpa0771a40ef48fcdfb7.free.beeceptor.com/jobs'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.body.codeUnits));
      final jobs = jsonResponse['data'] as List;

      return jobs.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception(
          "Failed to load job posts. Please try again at a later time.");
    }
  }

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 3.0),
          child: Text('Jobs'),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        actions: const [
          Icon(
            Icons.notifications_none_outlined,
            color: Colors.deepPurple,
            size: 22,
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        indicatorColor: Colors.transparent,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.work_outline,
              color: Colors.deepPurple,
            ),
            icon: Icon(Icons.work_outline),
            label: 'Jobs',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.person_outline,
              color: Colors.deepPurple,
            ),
            icon: Icon(Icons.person_outline),
            label: 'Resume',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.settings_outlined,
              color: Colors.deepPurple,
            ),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
      body: <Widget>[
        jobsPage(),
        resumePage(),
        settingsPage(theme),
      ][currentPageIndex],
    );
  }

  FutureBuilder<List<Post>> jobsPage() {
    return FutureBuilder(
      future: fetchAllPosts(),
      builder: (context, snap) {
        if (snap.hasData) {
          if (snap.data!.isEmpty) {
            return const Text('No jobs found.');
          }
          return ListView.builder(
            itemCount: snap.data?.length,
            itemBuilder: (BuildContext context, int index) {
              String dateString = '${snap.data?[index].updatedDate}';
              DateTime dateTime = DateTime.parse(dateString);
              String timeAgo = timeago.format(dateTime, locale: 'en');

              return Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10, top: 5),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: NetworkImage(
                                  '${snap.data?[index].companyLogo}'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 3.0),
                          child: Text('${snap.data?[index].jobRole}'),
                        ),
                        titleTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3.0),
                              child: Text(
                                '${snap.data?[index].companyName}',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3.0),
                              child: Text(
                                '${snap.data?[index].location} . ${snap.data?[index].site} . ${snap.data?[index].type}',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 16.0, bottom: 8.0),
                          child: Text(
                            timeAgo,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (snap.hasError) {
          return const Text('error in fetch');
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

//Settings page
  ListView settingsPage(ThemeData theme) {
    return ListView.builder(
      reverse: true,
      itemCount: 2,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Salam sir Rao. Wsalam wasi',
                style: theme.textTheme.bodyLarge!
                    .copyWith(color: theme.colorScheme.onPrimary),
              ),
            ),
          );
        }
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              'THIS IS NOT A REAL SETTINGS PAGEEEE',
              style: theme.textTheme.bodyLarge!
                  .copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
        );
      },
    );
  }

//Resume page
  Text resumePage() {
    return const Text(
      'Resume pageeeee',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
