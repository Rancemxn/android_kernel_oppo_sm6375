#include <linux/module.h>
#include <linux/types.h>

typedef enum {
    SECURE_BOOT_OFF = 0,
    SECURE_BOOT_ON_STAGE_1,
    SECURE_BOOT_ON_STAGE_2,
    SECURE_BOOT_UNKNOWN,
} secure_type_t;

secure_type_t get_secureType(void)
{
    return SECURE_BOOT_OFF;
}
EXPORT_SYMBOL_GPL(get_secureType);

MODULE_LICENSE("GPL");