#  Sendbird Test

## 과제 목표
Sendbird API를 이용하여 유저를 관리하는 SDK를 완성시키자.

## 아키텍처 
SDK의 아키텍처는 사용해본것이 없어서 기존에 사용하던 클린아키텍처에서 Present Layer을 제외한 Data Layer, Domain Layer로 아키텍처를 구성했습니다.
- Base Folder
    - 앱에서 전반적으로 사용되는 Extension, SBError등이 모여있습니다.
    - APIError
        - API에서 실패했을때 Decoding 하여 Custom Error로 만들기 위해 사용됩니다.
    - SBError
        - API를 호출하기전에 SDK에서 오류를 발생시켜 서버의 과부하를 최소화시킵니다.
- Data Layer
    - 서버와 통신하거나 내부 메모리 캐시데이터를 데이터를 가져오는데 필요한 코드가 모여있습니다.
    - Entity, Router, Repository를 제공합니다.
    - SBUserStorage를 구현한 UserStorageImplement를 제공합니다.
    - SBNetworkClient를 구현한 NetworkClientImplement를 제공합니다.
    - Request protocol을 채택하는 RequestType을 제공하는 CustomNetworkRequest이 존재합니다.
    - API에서 Decoding되는 Entity를 제공합니다.
    - Moya Library를 사용하여 SendbirRouter를 제공합니다.
- Domain Layer
    - SBUserManager를 구현한 UserManagerImplement를 제공합니다.
- CustomTest
    - MoyaRouterTests
        - API가 잘 작동하는지 확인하기 위한 Test입니다.
    - CustomManagerBaseTests
        - UserManagerBaseTests를 테스트하는 도중 추가적으로 테스트해보고 싶은것이 있어 개발한 Test입니다.
    - CustomUserStorageTests
        - UserStorageBaseTests를 테스트하는 도중 추가적으로 테스트해보고 싶은것이 있어 개발한 Test입니다.


### 과제하면서 고민했던 것들
- 현재 API를 호출할때마다 apiToken, appID를 파라미터로 전달하고 있습니다.
    - 이유는 중간에 아이디가 바뀌는 경우가 생기면 apiToken, baseURL다 바뀌어야 되기 때문에 apiToken, appID를 파라미터로 전달하기로 결정했는데 괜찮은 방법이있을까 고민했습니다.
- Request에 Date를 추가하여 POST는 1초에 한번 GET은 1초에 최대 10번만 호출하게 처리했습니다.
- ActorUserStorage 
    - thread safe와 비동기를 위해서 애플에서 제공하는 actor을 사용하면 안정성이 올라갈거 같았지만 protocol과 사용법을 너무 많이 변경해야 되서 개발하다가 중단하였습니다.
- actor을 사용하지 않게되면서 Custom DispatchQueue를 사용했습니다.
- UserStorageImplement 
    - 만약 한번에 여러개의 AppId의 유저를 컨트롤하는 경우가 생길 수도 있을거 같아서 NSCache에 appId를 키로 저장합니다.
    - users는 key는 userId, value는 SBUser를 저장하는 Dictionary(Hashtable)형태로 저장합니다.
        - userId로 유저를 받아올 때 해시테이블이기 때문에 속도가 빠릅니다. 
        - loop문을 사용할 수 있습니다
        - Array처럼 순서를 보장하지 않아도 됩니다.

### 과제하면서 좋았던점
- 보통 과제는 UI를 만드는 과제가 많았는데 SDK를 개발하는 과제여서 신선한 경험을 할 수 있어서 재밌었습니다.
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

