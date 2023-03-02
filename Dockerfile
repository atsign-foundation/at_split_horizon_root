FROM dart:2.19.2@sha256:9825f5fc2c98206cf8322b487e9c4f072040dfec2b2a8dca5a41983ef5501059 AS buildimage
ENV HOMEDIR=/atsign
ENV BINARYDIR=/usr/local/at
ENV USER_ID=1024
ENV GROUP_ID=1024
WORKDIR /app
COPY . .
RUN \
  mkdir -p $HOMEDIR/shrd ; \
  mkdir -p $BINARYDIR \
  dart pub get ; \
  dart pub update ; \
  dart compile exe bin/at_split_horizon_root.dart -o $BINARYDIR/shrd ; \
  addgroup --gid $GROUP_ID atsign ; \
  useradd --system --uid $USER_ID --gid $GROUP_ID --shell /bin/bash \
    --home $HOMEDIR atsign ; \
  chown -R atsign:atsign $HOMEDIR ; \
  cp ./atServers $HOMEDIR ; \
  cp ./*.pem $HOMEDIR ; \
  cp pubspec.yaml $HOMEDIR/
# Second stage of build FROM scratch
FROM scratch
COPY --from=buildimage /runtime/ /
COPY --from=buildimage /etc/passwd /etc/passwd
COPY --from=buildimage /etc/group /etc/group
COPY --from=buildimage --chown=atsign:atsign /atsign /atsign/
COPY --from=buildimage --chown=atsign:atsign /usr/local/at /usr/local/at/
WORKDIR /atsign/shrd
USER atsign
ENTRYPOINT ["/usr/local/at/shrd"]