export const Config = {
  port: parseInt(process.env.PORT || "8080"),
  originArrayCors: ['http://localhost', 'http://local-goemms.com', 'https://qa.goemms.com', 'https://goemms.com']
};
