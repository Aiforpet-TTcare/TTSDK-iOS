#!/bin/bash

# 사용자가 입력한 버전
echo "Enter the new version:"
read NEW_VERSION

# Podspec 파일 이름
PODSPEC="TTSDK-iOS.podspec"

# Podspec 파일에서 버전 업데이트
echo "Updating version in $PODSPEC to $NEW_VERSION..."
sed -i '' "s/spec.version      = .*/spec.version      = \"$NEW_VERSION\"/" $PODSPEC
sed -i '' "s/:tag => \".*\"/:tag => \"$NEW_VERSION\"/" $PODSPEC

# Git 커밋 및 푸시
echo "Committing and pushing changes to git..."
git add .
git commit -m "Update podspec version to $NEW_VERSION"

# 현재 브랜치 이름 가져오기
CURRENT_BRANCH=$(git branch --show-current)

# 브랜치가 없을 경우 'main'으로 설정
if [ -z "$CURRENT_BRANCH" ]; then
  CURRENT_BRANCH="main"
  git branch -M main
fi

# 태그 추가
git tag $NEW_VERSION

# 원격에 푸시
git push origin $CURRENT_BRANCH
git push origin $NEW_VERSION

# Podspec 검증
echo "Linting $PODSPEC..."
pod spec lint $PODSPEC

# 검증 성공 여부 확인
if [ $? -eq 0 ]; then
  echo "Lint successful, pushing to trunk..."
  pod trunk push $PODSPEC
  if [ $? -eq 0 ]; then
    echo "Successfully pushed $PODSPEC to CocoaPods trunk."
  else
    echo "Failed to push $PODSPEC to CocoaPods trunk."
    exit 1
  fi
else
  echo "Lint failed for $PODSPEC. Please fix the errors and try again."
  exit 1
fi
