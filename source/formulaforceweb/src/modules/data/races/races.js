const URL = '/api/races/';
let races = [];

export const getRaces = () =>
    fetch(URL)
        .then((response) => {
            if (!response.ok) {
                throw new Error('No response from server');
            }
            return response.json();
        })
        .then((result) => {
            races = result.summary;
            return races;
        });
