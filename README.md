# 🎓 MyFuture Application 

A personalized mobile application for high school students in choosing the right education and career pathways. Using a rule-based system to determine the personalization combining MBTI personality and RIASEC test. 

🏆 Award : Best of the Best Final Year Project in Faculty

## 📌 Problem Statement 
Many Malaysian students, particularly those from schools with fewer educational resources, may have limited exposure to the different education pathways and scholarship opportunities available after SPM.

MyFuture was developed to bring these resources together in a single platform and help students make more informed decisions about their education and future careers.

## 👩🏻‍💻 My Role 
I was responsible for the development of the MyFuture application, including:

- Designing the application interface
- Developing the mobile application using Flutter and Dart
- Implementing Firebase Authentication
- Designing and managing Firestore data
- Developing the career and personality assessment features
- Developing the scholarship functionality
- Developing the admin dashboard
- Testing and improving the application based on feedback

## 💻 Technologies 
- Dart
- Flutter
- Firebase Authentication 
- Cloud Firestore (NoSQL database)
- Firebase (Cloud Backend services)
- Rule based system 

# 🫆 Features 
## 🔐 User Authentication
- User registration and login (incl. email verification for first sign up)
- Forgot password functionality 
- Secure user authentication using Firebase Authentication
- User profile management (changing password)

## 🚸 Education Pathway Explorer
Explore different education pathways available after SPM, including :
- Matriculation
- A-Level
- Foundation
- Diploma
- Degree
- Other higher education pathways
- Any professional certificates (eg. ACCA)

Each pathway provides information to help students understand their options before making further decisions. 

## 💼 Career & Personality Assessment
MyFuture application includes assessment to help students personalized their career and best pathways based on their interest and personality. 

- Career assessment
- Personality assessment based on MBTI
- Results presented based on the student's responses
- Helps students explore potential career directions

The application calculates the user's responses and uses a rule-based scoring system to determine suitable career recommendations.

## 💡 Rule-Based Recommendations
Instead of using machine learning, MyFuture uses a rule-based recommendation system.

The system processes the user's assessment responses using predefined scoring rules and calculations to generate career recommendations.

This approach was chosen to provide more consistent and explainable results after an initial exploration of machine learning produced biased recommendations.

## 💰 Scholarship Finder 
Students can browse available scholarships and view important information such as :

- Scholarship name
- Eligibility
- Description
- Application deadline
- Scholarship status

Scholarships are automatically displayed as **OPEN** or **CLOSED** based on their application closing dates. **APPLY** button will automatically redirect students to the scholarships application website page. 

## 📱 Application Flow 
<img width="632" height="764" alt="Screenshot 2026-10-04 at 23 46 32" src="https://github.com/user-attachments/assets/75e32e1b-6570-4b69-a580-7ecbc1fbfb02" />
<img width="497" height="810" alt="Screenshot 2026-10-04 at 23 47 25" src="https://github.com/user-attachments/assets/23c5f283-9965-440f-99f3-9c6789f57c7c" />
<img width="570" height="790" alt="Screenshot 2026-10-04 at 23 48 00" src="https://github.com/user-attachments/assets/7951aedf-fcfd-4f2a-90d5-6c8a788e8eff" />

## 📚 What I learned
Through this project, I gained practical experience in:

- Mobile application development
- Flutter and Dart
- Firebase and NoSQL databases
- User authentication
- UI/UX design
- Database design
- Connecting application features to backend services
- Developing a project from an idea into a working application
- Ensuring the assessment scoring is correct based on the revised MBTI personality and RIASEC questions provide by school counselor


## 🔄 Development Journey 
During development, I initially explored using a machine learning approach for the career recommendation feature.

However, after testing the model, I found that the recommendations could become biased and did not consistently reflect the assessment results as intended.

Instead of forcing the machine learning approach into the application, I decided to revisit the problem and implement a rule-based recommendation system.

The final system calculates the user's assessment responses using predefined rules and scoring criteria before generating the recommended results.

This experience taught me that using a more complex technology is not always the best solution. For MyFuture, a rule-based approach provided results that were more predictable, transparent, and easier to validate.


## 🚀 Future Improvements
Some features I would like to explore in the future include:

- More personalized education pathway recommendations
- Integrating API for the scholarships opportunities
- Integrating AI for MBTI and RIASEC assessment results to provide more accurate education and career recommendation results. 
- Notifications for scholarship deadlines
- More detailed student progress tracking


