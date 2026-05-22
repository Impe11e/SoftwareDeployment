import fs from 'node:fs';

const CONFIG_PATH = '/etc/mywebapp/config.json';

const loadConfig = () => {
    try {
        if (!fs.existsSync(CONFIG_PATH)) {
            throw new Error(`Configuration file not found at ${CONFIG_PATH}`);
        }
        
        const data = fs.readFileSync(CONFIG_PATH, 'utf8');
        return JSON.parse(data);
    } catch (err) {
        console.error("Could not load configuration.");
        console.error(err.message);
        process.exit(1);
    }
};

const config = loadConfig();
export default config;