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

### Firestore의 한계점

파이어베이스에서 제공하는 파이어스토어는 요금제에 따라 다르지만, CRUD 작업에 있어서 횟수제한이 있다.

이 프로젝트에서는 게시판과 채팅영역에서 비중이 큰데 최대한 작업을 아끼되 사용자들에게 불편하지 않도록 하려고 노력했다.

<br>

- __게시판__

우선 게시판 탭에서 제일 먼저 보이는 것이 게시글 리스트다. 만약에 글이 1,000개가 있다고 하면 게시판 탭을 누를 때 마다 1,000개의 게시글을 읽어오는 것은 읽기 횟수에서나 메모리 측면에서나 비효율적이다.

그래서 일반적으로 리스트뷰에 적용하는 Pagination기법을 적용시켰다. 처음 보이는 게시글들을 최대 n개로 정해놓고, 스크롤을 하면 n개를 추가로 읽어오는 방식이라서 메모리와 횟수 관리 효율에 좋다.

그리고 '게시판'탭의 뷰를 그릴 때 마다 게시글 데이터 n개를 읽어오는 것도 다수의 사람이 이용했을 경우, 금방 읽기횟수가 채워질 것을 대비하여 '게시판'탭 뷰가 최초로 그려질 때 게시글 데이터들을 읽어오도록 했다.

나머지 최신글을 불러오는 것은 사용자가 수동으로 새로고침을 하여 볼 수 있도록 해놓았다.

특정 게시글을 탭하여 이동할때는 그 순간 특정 게시글 데이터를 불러오는 게 아니라, 뷰전환때 게시글 파라미터를 그대로 넘겨주어 데이터 읽기가 발생하지 않도록 하였다.

게시글을 작성한 후에도 리스트뷰에서 바로 읽어오는 것이 아닌, 수동 새로고침을 통해서 읽기 작업을 할 수 있도록 했다.

이렇게 하나라도 CRUD 작업 횟수를 줄이는 방법을 다방면으로 생각해냈고, 그 와중에도 사용자의 편의성을 놓치지 않으려고 노력했다.

<br>

- __채팅__

채팅은 게시판보다 사용자가 더 가볍게 이용할 수 있는 기능이기에 CRUD 작업량이 훨씬 많을 것이라 예상하고 방안을 생각했다.

채팅도 보통 지속적으로 하게되면 대화내용들이 쌓이기 때문에 마찬가지로 채팅뷰에 Pagination기법을 적용시켰다.

그리고 Pagination을 적용시켜도 대화를 많이한 채팅방에서 이전내용을 찾아본다고 스크롤을 올리게 된다면, 많은양의 읽기 작업을 하게 될 것이다.

이를 방지하기위해 채팅내용들을 Realm을 활용해 저장하도록 했다.

1. 채팅방을 열면 Realm에 저장된 채팅내용들을 설정된 데이터 개수(Paging)에 맞게 읽어옴
2. Firestore에 해당되는 채팅방의 새로운 채팅내용이 있는지 확인 (사용자가 채팅방에 마지막으로 읽은 날짜 기준)
3. 새로운 채팅내용 읽어온 후, Realm에서 읽어온 데이터와 병합
4. 날짜순으로 정렬 후 View에 그려냄

이렇게 처리하니 새로운 채팅내용 데이터만 읽기 횟수가 소모되어 Firestore의 CRUD 작업 횟수 제한에 대한 부담이 덜하게 되었다.

리스트가 되는 것들은 기본적으로 Paging처리 하는 게 좋은 것 같다.

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
