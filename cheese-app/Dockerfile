# Node.js app Docker file
FROM    node:4.4.3

# Update NPM to latest
RUN     npm update -g npm

# Install App
WORKDIR /
ADD     . ${WORKDIR}
RUN     npm install --progress=false --log-level=info


CMD     ["npm", "start"]
