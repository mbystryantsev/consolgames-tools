#pragma once

// Decrypt/encrypt data, returns state for continuation
unsigned int crypto(void* data, int size, unsigned int state = 0);
