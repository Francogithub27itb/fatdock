FROM dpage/pgadmin4:latest
  
USER root
RUN \
chmod 644 /usr/lib/sudo/sudoers.so && \
chown root:root /etc/sudoers && \
chown root:root -R /etc/sudoers.d/  && \
echo "pgadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER pgadmin