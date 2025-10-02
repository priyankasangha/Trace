import { getUserByEmail, createUser } from './userService.js';

// called after google OAuth returns user info
export async function handleGoogleLogin(googleProfile) {
    const { email, name, picture } = googleProfile;
    let user = await getUserByEmail(email).catch(() => null);

     // If no user exists, create one
    if (!user) {
        user = await createUser({
            email,
            name,
            profilePic: picture,
        });
    }

    return user;
}
