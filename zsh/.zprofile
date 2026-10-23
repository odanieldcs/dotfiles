# Login shell (once per terminal window): PATH and environment variables.
eval "$(/opt/homebrew/bin/brew shellenv)"

# React Native / Android (values from reactnative.dev "Set Up Your Environment")
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
