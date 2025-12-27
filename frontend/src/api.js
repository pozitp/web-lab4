import router from './main.js';

export async function api(url, options = {}) {
    const defaultOptions = {
        credentials: 'include',
        headers: {
            'Content-Type': 'application/json',
            ...options.headers
        }
    };
    const mergedOptions = { ...defaultOptions, ...options };
    const res = await fetch(url, mergedOptions);
    if (res.status === 401) {
        router.push('/');
        throw new Error('Unauthorized');
    }
    return res;
}
