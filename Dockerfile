FROM ubuntu:14.04
MAINTAINER Owen Ouyang "owen.ouyang@live.com"
ENV REFRESHED_AT 2017-07-31

ENV DEBIAN_FRONTEND noninteractive
# Download and untar SDK
ENV ANDROID_SDK_URL http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV ANDROID_SDK /usr/local/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools:$PATH

# License Id: android-sdk-license-ed0d0a5b
ENV ANDROID_COMPONENTS platform-tools,build-tools-25.0.2,android-25
# License Id: android-sdk-license-5be876d5
ENV GOOGLE_COMPONENTS extra-android-m2repository,extra-google-m2repository

# Support Gradle
ENV TERM dumb

RUN set -x \
 && : Install Oracle JDK 8 \
 && apt-get update \
 && apt-get install -y software-properties-common wget redir \
 && echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
 && echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections \
 && add-apt-repository ppa:webupd8team/java \
 && apt-get update \
 && apt-get install -y oracle-java8-installer oracle-java8-set-default \
 && : SDK licenses agreements \
 && mkdir -p "$ANDROID_SDK/licenses" || true \
 && echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_SDK/licenses/android-sdk-license" \
 && echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_SDK/licenses/android-sdk-preview-license" \
 && : Install android \
 && wget -qO- http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz | tar xz -C /usr/local --no-same-permissions \
 && chmod -R a+rX $ANDROID_HOME \
 && ls -l $ANDROID_HOME \
 && echo y | android update sdk --no-ui --all --filter "${ANDROID_COMPONENTS}" \
 && echo y | android update sdk --no-ui --all --filter "${GOOGLE_COMPONENTS}" \
 && echo y | android update sdk --no-ui --all -t `android list sdk --all|grep "SDK Platform Android 6.0, API 23"|awk -F'[^0-9]*' '{print $2}'` \
 && echo y | android update sdk --no-ui --all --filter sys-img-x86-android-23 --force \
 && echo n | android create avd --force -n "x86" -t android-23 --abi default/x86 \
 && : Update Intel HAXM \
 && echo y | android update sdk --no-ui --all --filter extra-intel-Hardware_Accelerated_Execution_Manager \
 && : Needed to be able to run VNC - bug of Android SDK \
 && mkdir ${ANDROID_HOME}/tools/keymaps \
 && touch ${ANDROID_HOME}/tools/keymaps/en-us \
 && : Install appium \
 && add-apt-repository ppa:chris-lea/node.js \
 && apt-get update \
 && apt-get -y install nodejs \
 && apt-get clean \
 && apt-get autoclean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD start.sh /start.sh

#  && npm install -g appium \
# && : echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-23 --force \
# && : echo n | android create avd --force -n "arm" -t android-23 --abi default/armeabi-v7a \

# Expose android port
EXPOSE 5555
# VNC port
EXPOSE 5900
# Appium
EXPOSE 4723

CMD /start.sh
