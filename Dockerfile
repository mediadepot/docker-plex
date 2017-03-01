FROM debian:jessie
MAINTAINER jason@thesparktree.com

#Create internal depot user (which will be mapped to external DEPOT_USER, with the uid and gid values)
RUN groupadd -g 15000 -r depot && useradd --uid 15000 -r -g depot depot

#Install base applications + deps
RUN apt-get -q update && \
    apt-get install -qy --force-yes avahi-daemon avahi-utils curl && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

#Create Plex folder structure & set as volumes
RUN mkdir -p /srv/plex/app && \
	mkdir -p /srv/plex/data


#Install Plex
RUN curl -L https://downloads.plex.tv/plex-media-server/1.3.4.3285-b46e0ea/plexmediaserver_1.3.4.3285-b46e0ea_amd64.deb -o plexmediaserver.deb && \
	dpkg -i plexmediaserver.deb && \
	rm  /plexmediaserver.deb

#Configure plexmediaserver to be container friendly,
#Stop the autostarted plex service, and delete the service file
#RUN service plexmediaserver stop && \
#    update-rc.d -f plexmediaserver remove && \
#    rm -f /etc/init.d/plexmediaserver && \
#    pkill -9 -e Plex

#Move the application files
RUN cp -R /usr/lib/plexmediaserver/. /srv/plex/app && \
    rm -rf /usr/lib/plexmediaserver

RUN chown -R depot:depot /srv/plex

#Copy over start script
ADD ./start.sh /srv/start.sh
RUN chmod u+x  /srv/start.sh

VOLUME ["/srv/plex/data"]

EXPOSE 32400

CMD ["/srv/start.sh"]