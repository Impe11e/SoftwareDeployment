import app from './app.js';
import config from './config/index.js';
import { initDatabase } from './db/pool.js';

await initDatabase();

const socketFd = process.env.LISTEN_FDS > 0 ? { fd: 3 } : null;
const serverArgs = socketFd ? [socketFd] : [config.server?.port, config.server?.host];

app.listen(...serverArgs, () => {
    if (socketFd) {
        console.log(`Server started via systemd socket`);
    } else {
        console.log(`Server started on http://${config.server?.host}:${config.server?.port}`);
    }
});