#  Sendbird Test




### 해야되는것
- jwt 추가
- Platform API 응답을 in-memory cache를 통해 SDK 내에 캐싱 
- createUser 성공 시 캐시
- getUser 캐시에서 불러오고 없으면 GET 캐시 저장
- getUsers 캐시에 저장하고 Limit 10
- create, upsert할 때 user_id, profile, nickname 길이 확인해서 에러 떨궈주자.


### 완료


### 과제하면서 좋았던점
- 보통 과제는 UI를 만드는 과제가 많았는데 SDK를 개발하는 과제여서 신선해서 재밌었다.
특히 Test를 돌리는게 재밌었으며 멀티쓰레드 관련해서 공부하는게 좋았음.


### 과제 질문 history

Q1. 다운로드 받은 프로젝트에 Mock 폴더에 있는 파일들이 누락된거 같습니다.
A1. 외부 라이브러리 자유롭게 활용하셔도 무관하시다고 합니다.

Q2. 외부 라이브러리를 사용해도 상관없는지 궁금합니다.
A2. Mock 폴더는 비워두는 것이 맞고 이부분은 기능과는 무관한 폴더라 삭제 예정이시라고 합니다.

Q3. UserManagerBaseTests파일의 함수 testRateLimitGetUser
    - Get API는 Free Tiral에서 1초에 10개 Limit이 걸려있는데 API에서 Fail을 주는게 아니라 디바이스 내부에서 Fail을 주는건가요? (API에서 정상작동 해서 여쭤봅니다.)
A3. API는 정상동작 하지만 해당 SDK에서 API 요청 전에 에러를 주어 API 요청이 들어가지 않게 방어해야합니다

Q4. UserManagerBaseTests파일의 함수 testRateLimitCreateUser 
    - POST는 Free Tiral에서 1초에 5개만 사용할 수 있어서 5개가 성공하고 6개가 실패되어야 할거 같은데 테스트코드에서는 10개가 성공되고 1개가 실패됬을때 테스트통과인데 POST도 1초에 10개까지 성공이 가능한게 맞나요?
    - userId가 같아서 1개만 성공하고 10개가 실패될거 같은데 성공이 10개 실패가 1개 맞을까요?
    - API에서 fail을 주지 않는데 클라이언트 내부에서 처리하면 되나요?
A4. POST는 명시한 것처럼 1초에 1번만 요청을 보내야하고 그 이상의 요청이 들어오면 모두 SDK에서 rate limit으로 인한 실패 에러를 주어야 합니다
    - rate limit 알고리즘은 다양한 방법이 있으므로 2번째 요청을 어떻게 처리할 지는 후보자의 판단에 따라 구현하시면 됩니다   

Q5. UserManagerBaseTests파일의 함수 testRateLimitCreateUsers
    - 요청을 12개를 보냈는데 성공이 5개가 되고 실패가 7개가 되어야 할거같은데 테스트 통과는 5개성공 1개실패라고 되어있는데 어떤게 맞는건지 알 수 있을까요?
    - userId가 모두 같아서 성공 1개가 되고 실패 11개가 될거같은데 확인부탁드려요.
A5. 동일합니다. API가 정상 동작하는 것과 별개로 SDK 측의 rate limit이 걸려야 합니다. rate limit 은 1/sec 입니다

Q6. 과제 문서 3page의 createUsers를 보면 Local rate limit: 초당 User 1명 생성. 초당 1명 이상의 User를 생성해서는 안됩니다. 이라는 부분이 있는데
    한번에 createUsers 파라미터에 UserManagerBaseTests파일의 testCreateUsers() 처럼 params를 2개주면 실패가 되어야 하는건지 아니면 내부적으로 1초 딜레이를 걸어서 성공은 하되 1초이상이 걸려야 하는지 궁금합니다.
A6. 번의 답과 동일합니다. rate limit 을 어떻게 처리하는지는 알고리즘을 어떤 방식을 고르냐에 따라서 다르기 때문에 후보자의 판단에 맞게 구현하시면 됩니다. 큰 전제는 1초에 1번만 요청이 들어와야 한다는 것 입니다

