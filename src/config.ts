export const Config = {
  port: parseInt(process.env.PORT || "3000"),
  secretUrl: process.env.SECRET_URL || "/SECRET",
  originArrayCors: [
    "http://localhost",
    "http://local-goemms.com",
    "https://qa.goemms.com",
    "https://goemms.com",
  ],
};
