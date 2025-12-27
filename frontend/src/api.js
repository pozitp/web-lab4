import router from './main.js';

export async function api(url, options = {}) {
    const res = await fetch(url, options);
    if (res.status === 401) {
        router.push('/');
        throw new Error('Unauthorized');
    }
    return res;
}
