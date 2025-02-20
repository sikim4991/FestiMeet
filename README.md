# FestiMeet

![Image](https://github.com/user-attachments/assets/1f4661b7-9288-4fff-84e2-780c086744ff)

<br>

## 소개

__각 지역에서 진행하는 축제들을 확인하고__

__같이 갈 친구들을 찾아봐요!__

- 개발 기간 : 2024.09 - 2024.12

- `Swift 6.0.2` `Xcode 16.2` `iOS 17.0`

- `Swift` `UIKit` `RxSwift` `RxCocoa` `CodeBase(Programmatically)` `CocoaPods` `SPM`

- `GoogleSignIn` `AppleSignIn` `NaverSignIn` `KakaoSignIn` `NaverMaps` `Firebase` `OpenAPI` `Alamofire` `Realm` `Git/GitHub` `Figma` 

<br>

## 주요 기능

- 축제 정보

날짜와 지역을 선택하면 그에 맞는 축제들을 확인할 수 있어요.

또한 검색도 가능하니 궁금했던 축제에 대한 정보를 알고싶으시면 검색도 활용해보세요.

<br>

- 게시판 (로그인 필요)

축제에 대한 글을 작성할 수 있으며, 글 작성 내에서 축제를 선택하면

같이가고싶은 축제를 다른 사람들에게 보여줄 수 있어요.

또한 댓글로 다양한 의견을 나눌 수 있어요.

<br>

- 채팅 (로그인 필요)
  
게시판에서 같이가고싶은 사람을 찾았다면, 채팅으로 약속을 잡을 수 있어요.

## 구현 영상

|`홈 탭`|`축제정보 탭`|`축제 검색`|
|:---:|:---:|:---:|
|![Image](https://github.com/user-attachments/assets/78346090-5d21-475d-b5ec-3fef2f2ae08f)|![Image](https://github.com/user-attachments/assets/00022035-e09f-4264-b439-67116b21438b)|![Image](https://github.com/user-attachments/assets/f2df88b6-e7a2-4315-a033-26c5bb3ed544)|
|`축제 상세정보`|`로그인(1)`|`로그인(2)`|
|![Image](https://github.com/user-attachments/assets/78f202c6-06bc-4530-9bf4-2127454fdaab)|![Image](https://github.com/user-attachments/assets/facbfe73-a92f-49ea-9508-a78b79fe9e3c)|![Image](https://github.com/user-attachments/assets/7ca41969-d372-4bd5-b2eb-7c2934f2b436)|
|`게시글 작성`|`게시글 확인`|`댓글 작성`|
|![Image](https://github.com/user-attachments/assets/eeccdc9a-ebd3-488d-9d7a-163cab7c9631)|![Image](https://github.com/user-attachments/assets/4b3c9d15-ea60-4335-bae3-91315987b39d)|![Image](https://github.com/user-attachments/assets/cd00e6db-0f14-4ee2-baf1-af14935a8a66)|
|`채팅(1)`|`채팅(2)`|`채팅(3)`|
|![Image](https://github.com/user-attachments/assets/b04289f8-7d80-4fd4-867d-33bcbd8da650)|![Image](https://github.com/user-attachments/assets/0575277f-c0e9-420a-9718-5e9ef4000c4b)|![Image](https://github.com/user-attachments/assets/7f94a431-f4e2-4a0b-8972-d50264a13f49)|
|`프로필 사진 변경`|-|-|
|![Image](https://github.com/user-attachments/assets/ea4c5cb6-5e43-4774-b37e-a3ea4e3580da)|-|-|

<br>

## 이슈

<br>

## 아키텍처

__MVVM(Model-View-ViewModel)__ 디자인 패턴 적용
```
🗂FestivalTogether
 ┣ 🗂FestivalTogether
 ┃ ┣ 🗂Service
 ┃ ┃ ┣ 🗂Festival
 ┃ ┃ ┗ 🗂Firebase
 ┃ ┣ 🗂Model
 ┃ ┣ 🗂View
 ┃ ┃ ┣ 🗂Home
 ┃ ┃ ┣ 🗂FestivalInformation
 ┃ ┃ ┣ 🗂Community
 ┃ ┃ ┣ 🗂Chatting
 ┃ ┃ ┗ 🗂MyPage
 ┃ ┣ 🗂ViewControlelr
 ┃ ┃ ┣ 🗂Home
 ┃ ┃ ┣ 🗂FestivalInformation
 ┃ ┃ ┣ 🗂Community
 ┃ ┃ ┣ 🗂Chatting
 ┃ ┃ ┗ 🗂MyPage
 ┃ ┣ 🗂Extension
 ┃ ┗ 🗂Resource
 ┃   ┣ 🗂Animation
 ┃   ┣ 🗂FCM
 ┃   ┗ 🗂Fonts
 ┣ 🗂Product
 ┣ 🗂Pods
 ┗ 🗂Frameworks
🗂Pods
 ┣ 🗂Frameworks
 ┣ 🗂Pods
 ┣ 🗂Product
 ┗ 🗂Targets Support Files
```

## 회고
