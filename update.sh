#!/bin/bash

# 로그 파일 설정
LOG_FILE="update_podspec.log"
exec > >(tee -i $LOG_FILE)
exec 2>&1

echo "Starting podspec update at $(date)"

# 사용자로부터 새 버전과 브랜치 이름 입력 받기
echo "Enter the new version:"
read NEW_VERSION

if [[ -z "$NEW_VERSION" ]]; then
    echo "Version cannot be empty. Exiting."
    exit 1
fi

echo "Enter the branch name [default: release]:"
read BRANCH

# 브랜치 이름이 입력되지 않으면 기본값 'release' 사용
BRANCH=${BRANCH:-release}

# 사용자 확인
echo "You are about to update the version to $NEW_VERSION on branch '$BRANCH'. Proceed? (y/n)"
read CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Podspec 파일 이름
PODSPEC="TTSDK-iOS.podspec"

# Podspec 파일이 존재하는지 확인
if [[ ! -f "$PODSPEC" ]]; then
    echo "Podspec file '$PODSPEC' does not exist. Exiting."
    exit 1
fi

# Podspec 파일에서 버전 업데이트
echo "Updating version in $PODSPEC to $NEW_VERSION..."
sed -i '' "s/spec.version      = .*/spec.version      = \"$NEW_VERSION\"/" $PODSPEC
sed -i '' "s/:tag => \".*\"/:tag => \"$NEW_VERSION\"/" $PODSPEC

# Git 브랜치 체크아웃 (존재하지 않으면 새로 생성)
echo "Switching to branch '$BRANCH'..."
git checkout $BRANCH 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Branch '$BRANCH' does not exist. Creating and switching to '$BRANCH'..."
    git checkout -b $BRANCH
    if [ $? -ne 0 ]; then
        echo "Failed to create and switch to branch '$BRANCH'. Exiting."
        exit 1
    fi
fi

# Git 커밋
echo "Committing changes..."
git add $PODSPEC
git commit -m "Update podspec version to $NEW_VERSION"
if [ $? -ne 0 ]; then
    echo "Git commit failed. Exiting."
    exit 1
fi

# Git 태그 추가
echo "Creating git tag '$NEW_VERSION'..."
git tag $NEW_VERSION
if [ $? -ne 0 ]; then
    echo "Git tag creation failed. Exiting."
    exit 1
fi

# Git 푸시
echo "Pushing changes to branch '$BRANCH'..."
git push origin $BRANCH
if [ $? -ne 0 ]; then
    echo "Git push to branch '$BRANCH' failed. Exiting."
    exit 1
fi

echo "Pushing tag '$NEW_VERSION'..."
git push origin $NEW_VERSION
if [ $? -ne 0 ]; then
    echo "Git push for tag '$NEW_VERSION' failed. Exiting."
    exit 1
fi

# Podspec 검증 및 트렁크 푸시
echo "Linting $PODSPEC..."
pod spec lint $PODSPEC
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

echo "Version update and deployment completed successfully at $(date)."
