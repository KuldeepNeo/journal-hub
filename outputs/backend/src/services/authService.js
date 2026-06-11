import bcrypt from 'bcrypt';
import crypto from 'crypto';
import { v4 as uuidv4 } from 'uuid';
import userRepository from '../repositories/userRepository.js';
import verificationRepository from '../repositories/verificationRepository.js';
import emailService from './emailService.js';
import { ApiError } from '../middleware/errorHandler.js';

export const authService = {
  async registerUser({ fullName, email, password }) {
    // 1. Check duplicate email
    const existingUser = await userRepository.findByEmail(email);
    if (existingUser) {
      throw new ApiError(409, 'DUPLICATE_EMAIL', 'Email address is already registered');
    }

    // 2. Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // 3. Create user record
    const userId = `u-${uuidv4()}`;
    const userRecord = {
      userId,
      fullName,
      email,
      passwordHash,
      accountStatus: 'Pending'
    };
    const user = await userRepository.createUser(userRecord);

    // 4. Set hardcoded verification token to '123456' for demo
    const verificationId = `v-${uuidv4()}`;
    const token = '123456';
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();

    await verificationRepository.createToken({
      verificationId,
      userId,
      token,
      expiresAt
    });

    // 5. Skip email delivery for demo purposes
    // await emailService.sendVerificationEmail(email, token);

    return user;
  },

  async verifyEmail(token) {
    // 1. Retrieve verification record
    const tokenRecord = await verificationRepository.findByToken(token);
    if (!tokenRecord) {
      throw new ApiError(400, 'INVALID_TOKEN', 'Verification token is invalid');
    }

    // 2. Check expiration
    const expiresAt = new Date(tokenRecord.expires_at);
    if (expiresAt < new Date()) {
      throw new ApiError(410, 'TOKEN_EXPIRED', 'Verification token has expired');
    }

    // 3. Update status to Verified
    await userRepository.updateUserStatus(tokenRecord.user_id, 'Verified');

    // 4. Mark token as used
    await verificationRepository.markTokenAsUsed(tokenRecord.verification_id);

    return {
      status: 'SUCCESS',
      message: 'Email verified successfully'
    };
  }
};

export default authService;
