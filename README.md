# 마이슐랭
## 마이슐랭이란?
* <img src = "https://user-images.githubusercontent.com/89832278/224884487-fc64667b-dfff-4d7c-8a6e-3db4732df1b8.png" width="70">  

* 자신이 좋아하는, 가보고 싶은 식당을 사진과 함께 저장할수 있습니다.   
* 미슐랭에서 점수를 주듯 자기만의 기준으로 식당을 평가할수 있습니다.
* 카테고리와 태그로 식당을 분류하고 검색 할 수 있습니다.
* 좋아하는 식당을 잊지 말고 기억해두세요.

## 프로젝트 개발 환경
* Flutter version 3.7.5
* Dart version 2.19.2
* 사용 DB : Firestore, Firebase storage
* 사용 IDE : Android Studio

## 다운로드 링크
 마이슐랭은 구글 플레이스토어, 애플 앱스토어에서 다운로드 받을 수 있습니다.

* [<img src = "https://user-images.githubusercontent.com/89832278/224879405-e9787d56-f534-47b2-bbf6-55e1a2d70cc0.png" width="120">](https://play.google.com/store/apps/details?id=com.njw9108.recommend_restaurant)  
  
* [<img src = "https://user-images.githubusercontent.com/89832278/224879371-8440c9dc-57fa-427b-b598-121b933ac2eb.png" width="120">](https://apps.apple.com/us/app/%EB%A7%88%EC%9D%B4%EC%8A%90%EB%9E%AD/id6446059984)  

## 주요 기능
- ✅ SNS 로그인(카카오톡, 구글, 애플)
- ✅ 식당정보의 CRUD (with firebase)
- ✅ [카카오 로컬](https://developers.kakao.com/docs/latest/ko/local/common) API를 활용한 식당 검색 기능
- ✅ 저장된 식당의 정렬 기능(날짜순, 별점순, 이름순)
- ✅ 자신이 저장해둔 카테고리, 태그를 활용한 검색 기능
- ✅ 마음에 드는 식당은 좋아요 표시 기능

## 사용 라이브러리

### 상태관리
* Provider : 6.0.5

### 라우팅
* Go router : 6.0.4

### 로컬 DB
* flutter_secure_storage : 8.0.0

### http 메소드
* Dio : 4.0.6

### 모델 생성
* json_serializable : 6.6.0

### firebase
* firebase_auth: 4.2.6
* cloud_firestore: 4.4.0
* firebase_storage: 11.0.11
* firebase_remote_config: 3.0.13

## 주요 화면 및 설명

### 1. 로그인 화면

<img src = "https://user-images.githubusercontent.com/89832278/224888141-c15c24d9-abec-483b-8d19-c9d5406e65e7.PNG" width="180">

SNS 간편 로그인을 제공하는 화면입니다. [Firebase Auth](https://firebase.google.com/docs/auth?hl=ko)를 사용하여 인증을 사용했습니다.

* [구글 로그인](https://pub.dev/packages/google_sign_in)과 [애플 로그인](https://pub.dev/packages/sign_in_with_apple)은 제공되는 라이브러리를 사용하여 사용자 정보를 얻고, Firebase auth와 연결했습니다.
* 카카오 로그인은 [카카오 로그인 SDK](https://developers.kakao.com/docs/latest/ko/kakaologin/flutter)를 사용하여 인증을 하고 Firebase Auth에서 인가를 받기 위해 [Firebase Functions](https://firebase.google.com/docs/functions?hl=ko)를 사용하여 Custom Token을 받아 진행했습니다.

### 2. 홈 화면

2-1. 카테고리, 태그 추가&편집

* 식당 정보를 작성할때 사용되는 카테고리, 태그를 편집(추가, 삭제) 할 수 있습니다.
* 카테고리, 태그는 검색을 위해 사용 됩니다.

|  |  |  |
| :--- | :--- | :--- |
| <img src = "https://user-images.githubusercontent.com/89832278/224945165-28d74f91-34d3-4115-a5c3-f05c3093edc7.PNG" width="180"> | <img src = "https://user-images.githubusercontent.com/89832278/224945181-0db0c61d-d883-49dc-866d-0a7f3c80d21e.PNG" width="180"> | <img src = "https://user-images.githubusercontent.com/89832278/224945189-cb324c51-32a5-42f2-810d-59c806f9fe68.PNG" width="180"> |


2-2. 카테고리, 태그 검색

* 카테고리와 태그를 사용해서 식당을 검색 할 수 있습니다.

|  |  |  |  |
| :--- | :--- | :--- | :--- |
| <img src = "https://user-images.githubusercontent.com/89832278/224948537-d65e2ee2-4c14-4d2a-b5cc-18eedde6e224.PNG" width="180"> | <img src = "https://user-images.githubusercontent.com/89832278/224948557-94110c70-7b55-4324-b3e6-12b8b2270024.PNG" width="180"> | <img src = "https://user-images.githubusercontent.com/89832278/224948584-78393373-0080-4d84-9223-a89c2549ea7f.PNG" width="180"> | <img src = "https://user-images.githubusercontent.com/89832278/224948587-5734840e-5c77-4072-b412-fe41d7b3c5a3.PNG" width="180"> |

2-3. 내가 좋아하는 식당 & 미방문 식당

* 내가 좋아하는 식당 : 내가 좋아요를 표시한 식당들을 모아서 보여줍니다.
* 미방문 식당 : 방문하지 않은 식당을 모아서 보여줍니다.

|  |
| :--- |
| <img src = "https://user-images.githubusercontent.com/89832278/224949519-2a24aab6-705e-4194-8be4-40c4dc40f133.PNG" width="180"> |


### 3. 식당 화면

3-1. 식당 목록

* 저장된 식당 리스트를 볼 수 있습니다.
* 정렬 기능이 있습니다.

|  |  | 
| :--- | :--- |
| <img src = "https://user-images.githubusercontent.com/89832278/224951669-4aea771c-53d5-41e5-9139-fdbc89fcae80.PNG" width="180"> | <img src = "https://user-images.githubusercontent.com/89832278/224951677-71d6a4c1-35f4-4946-bbac-9070d0028ec6.PNG" width="180"> |  


3-2. 식당 추가

* 식당을 추가할 수 있습니다.
* 정보를 직접 입력하거나 식당 이름으로 검색할 수 있습니다.([카카오 로컬](https://developers.kakao.com/docs/latest/ko/local/common) API 사용)
* 검색 결과는 scoll 이벤트를 받아 pagination으로 자동 추가 할 수 있도록 했습니다.(최대 45개 결과)
* 최대 3장의 이미지를 첨부할 수 있습니다.


|  |  |  |  |  |
| :--- | :--- | :--- | :--- | :--- |
| <img src = "https://user-images.githubusercontent.com/89832278/224953828-fd482609-77a7-4e12-8b76-5a4768d0536d.PNG" width="180"> | <img src = "https://user-images.githubusercontent.com/89832278/224953834-3d7674c3-5cb5-4de1-9ea8-01f492ac732d.PNG" width="180"> | <img src = "https://user-images.githubusercontent.com/89832278/224953836-ecdaf933-6ef0-4e59-984c-3012cf4833ac.PNG" width="180"> | <img src = "https://user-images.githubusercontent.com/89832278/224953839-6e5b212d-79b6-4406-900c-74cd6c228ecd.PNG" width="180"> | <img src = "https://user-images.githubusercontent.com/89832278/224953842-cfa599a5-41df-4385-8e51-1c2532717fac.PNG" width="180"> |


3-3. 식당 상세 화면

* 작성한 식당 정보를 확인 할 수 있습니다.
* 좋아요 표시를 할 수 있습니다.
* 게시글의 수정, 삭제를 할 수 있습니다.


|  |  |
| :--- | :--- |
| <img src = "https://user-images.githubusercontent.com/89832278/224955621-a3a7fd87-9113-4778-9a8c-a3a95bc0cc94.PNG" width="180"> | <img src = "https://user-images.githubusercontent.com/89832278/224955926-2e4c180c-54fc-4234-8808-67cf0ec776d5.PNG" width="180"> |


### 4. 프로필 화면

* 이름 정보와 버전을 확인 할 수 있습니다.
* 이름 정보를 수정 할 수 있습니다.
* 로그아웃, 회원 탈퇴 기능이 있습니다.

|  |  |  |
| :--- | :--- | :--- |
| <img src = "https://user-images.githubusercontent.com/89832278/224957464-07960076-b736-4dc9-a437-3b47ebb301d4.PNG" width="180"> | <img src = "https://user-images.githubusercontent.com/89832278/224957469-851b3723-b0f3-4e52-bcd6-f027bd808d22.PNG" width="180"> | <img src = "https://user-images.githubusercontent.com/89832278/224957475-8b39288a-45d7-4033-a1e0-eb3bc67fbc7e.PNG" width="180"> |

