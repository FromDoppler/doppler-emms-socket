#!/usr/bin/env node

/**
 * This is a sample HTTP server.
 * Replace this with your implementation.
 */

import "dotenv/config";
import { createServer, IncomingMessage, ServerResponse } from "http";
import { resolve } from "path";
import { fileURLToPath } from "url";
import { Config } from "./config.js";
import { Server } from "socket.io";

const nodePath = resolve(process.argv[1]);
const modulePath = resolve(fileURLToPath(import.meta.url));
const isCLI = nodePath === modulePath;

export default function main(port: number = Config.port) {
  const requestListener = (
    request: IncomingMessage,
    response: ServerResponse
  ) => {
    response.setHeader("content-type", "text/plain;charset=utf8");
    response.writeHead(200, "OK");
    const url = request.url;

    if (url === Config.secretUrl && request.method === "POST") {
      io.emit("state", "refresh");
      response.write("emit refresh");
      response.end();
    }

    if (url === "/" && request.method === "GET") {
      response.write("TEST Sockets.io");
      response.end();
    }
  };

  const server = createServer(requestListener);

  if (isCLI) {
    server.listen(port);
    // eslint-disable-next-line no-console
    console.log(`Listening on port: ${port}`);
  }

  const io = new Server(server, {
    cors: { origin: Config.originArrayCors },
  });

  return server;
}

if (isCLI) {
  main();
}
