# Client

## 실행 방법
- flutter, android SDK를 설치해주세요.
  - flutter doctor를 통해 완료되지 않은 설치사항이 있는지 확인 후 모든 문제를 해결해주세요.
- `local.properties` 파일에 다음의 두 줄을 추가해주세요. 발급 받은 Naver map client id와 kakao native app key를 등록하는 과정입니다.
```
naver.map.CLIENT_ID=[naver.map.CLIENT_ID]
kakao.native.app.key=[KAKAO Native APP KEY]
```
- `lib/app/modules/views/my_location_page.dart` line 370의 [your kakao rest api key]를 발급받은 kakao rest api key로 교체해주세요.
- Server 실행 시 받은 domain을 다음 위치에 넣어주세요
```
- lib/app/modules/views/alarm_page.dart line 1170 String domain = "[domain 값]"
- lib/app/modules/views/walk_page.dart line 455 String domain = "[domain 값]"
- lib/app/modules/views/bus_page.dart line 620 String domain = "[domain 값]"
- lib/app/modules/views/subway_page.dart line 618 String domain = "[domain 값]"
- lib/app/modules/views/taxi_page.dart line 470 String domain = "[domain 값]"
```

## 브랜치 관리 규칙

- `master` : 정식 배포용
- `develop` : 다음 버전 개발용
    - `master`에서 분기, 작업 후 `master`로 병합
- `feature/기능명` : 특정 기능 개발용
    - `develop`에서 분기, 작업 후 `develop`으로 병합
- `hotfix` : `master` 브랜치의 오류 수정용
    - `master`에서 분기, 작업 후 `master`로 병합

## 커밋 메세지 규칙
제목 작성 시, 커밋 유형에 맞는 `[Type]`을 앞에 붙여주세요. 

- `[FEAT ADD/UPDATE/REMOVE]` 기능 추가/수정/삭제
- `[FIX]` 버그 수정
- `[DOCS]` 문서 수정
- `[STYLE]` 코드 포맷팅
- `[REFACTOR]` 코드 리팩토링
- `[TEST]` 테스트 코드
- `[BUILD]` 빌드 파일 수정
- `[CHORE]` 기타 파일 수정
