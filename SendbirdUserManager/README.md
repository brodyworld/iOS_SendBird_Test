#  Sendbird Test






### 해야되는것
- jwt 추가
- Platform API 응답을 in-memory cache를 통해 SDK 내에 캐싱 
- createUser 성공 시 캐시
- getUser 캐시에서 불러오고 없으면 GET 캐시 저장
- getUsers 캐시에 저장하고 Limit 10



### 과제하면서 좋았던점
- 보통 과제는 UI를 만드는 과제가 많았는데 SDK를 개발하는 과제여서 신선해서 재밌었다.
특히 Test를 돌리는게 재밌었다.



### 질문
1. testsRateLimitGetUser 
    - dispatchGroup.wait() 을 메인쓰레드에서 하면 데드락이 걸리지 않나요?
    - Get API는 Free Tiral에서 1초에 10개 Limit이 걸려있는데 API에서 Fail을 주는게 아니라 디바이스 내부에서 Fail을 주는건가요? (API에서 정상작동 해서 여쭤봅니다.)

2. testRateLimitCreateUser 
    - POST는 Free Tiral에서 1초에 5개만 사용할 수 있어서 5개가 성공하고 6개가 실패되어야 하는거 같은데 10개가 성공되고 1개가 실패되어야 하는지 궁금합니다.
    - userId가 같아서 1개만 성공할 거 같은데 확인 부탁드려요.

3. testRateLimitCreateUsers
    - 요청을 12개를 보냈는데 성공이 5개가 되고 실패가 7개가 되어야 하는거 아닌가요?
    - 그리고 userId가 같아서 성공 1개가 되고 실패 11개가 되어야 하는거 아닌가요?

4. 과제 문서에 보면 Local rate limit: 초당 User 1명 생성. 초당 1명 이상의 User를 생성해서는 안됩니다. 이라는 부분이 있는데
1초에 1개이상의 create user 를 사용하지 못하게 내부에서 막는게 맞나요?

