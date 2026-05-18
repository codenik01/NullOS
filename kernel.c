typedef unsigned char  u8;
typedef unsigned short u16;
typedef unsigned int   u32;

u16* video_memory = (u16*)0xB8000;

u32 cursor_x = 0;
u32 cursor_y = 0;

u8 current_color = 0x0F;

/* =========================================
   PORT IO
========================================= */

static inline void outb(u16 port, u8 value)
{
    __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

static inline u8 inb(u16 port)
{
    u8 ret;

    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));

    return ret;
}

/* =========================================
   CURSOR
========================================= */

void update_cursor()
{
    u16 pos = cursor_y * 80 + cursor_x;

    outb(0x3D4, 0x0F);
    outb(0x3D5, (u8)(pos & 0xFF));

    outb(0x3D4, 0x0E);
    outb(0x3D5, (u8)((pos >> 8) & 0xFF));
}

/* =========================================
   SCROLL
========================================= */

void scroll()
{
    if(cursor_y < 25)
        return;

    for(int y = 1; y < 25; y++)
    {
        for(int x = 0; x < 80; x++)
        {
            video_memory[(y - 1) * 80 + x] =
            video_memory[y * 80 + x];
        }
    }

    for(int x = 0; x < 80; x++)
    {
        video_memory[24 * 80 + x] =
        (current_color << 8) | ' ';
    }

    cursor_y = 24;
}

/* =========================================
   CLEAR SCREEN
========================================= */

void clear_screen()
{
    for(int i = 0; i < 80 * 25; i++)
    {
        video_memory[i] = 0x0720;
    }

    cursor_x = 0;
    cursor_y = 0;

    update_cursor();
}

/* =========================================
   PRINT CHAR
========================================= */

void print_char(char c)
{
    if(c == '\n')
    {
        cursor_x = 0;
        cursor_y++;

        scroll();
        update_cursor();

        return;
    }

    video_memory[cursor_y * 80 + cursor_x] =
    (current_color << 8) | c;

    cursor_x++;

    if(cursor_x >= 80)
    {
        cursor_x = 0;
        cursor_y++;
    }

    scroll();

    update_cursor();
}

/* =========================================
   PRINT STRING
========================================= */

void print(const char* str)
{
    int i = 0;

    while(str[i])
    {
        print_char(str[i]);
        i++;
    }
}

/* =========================================
   STRING COMPARE
========================================= */

int strcmp(const char* a, const char* b)
{
    int i = 0;

    while(a[i] && b[i])
    {
        if(a[i] != b[i])
            return 0;

        i++;
    }

    return a[i] == b[i];
}

/* =========================================
   INPUT
========================================= */

char keyboard_map[128] =
{
    0,27,'1','2','3','4','5','6','7','8','9','0','-','=',8,9,
    'q','w','e','r','t','y','u','i','o','p','[',']',13,0,
    'a','s','d','f','g','h','j','k','l',';',39,'`',0,'\\',
    'z','x','c','v','b','n','m',',','.','/',0,'*',0,' '
};

char keyboard_read()
{
    while(!(inb(0x64) & 1));

    u8 scancode = inb(0x60);

    if(scancode >= 128)
        return 0;

    return keyboard_map[scancode];
}

/* =========================================
   COMMAND BUFFER
========================================= */

char command_buffer[128];
int buffer_index = 0;

/* =========================================
   SHELL
========================================= */

void show_prompt()
{
    current_color = 0x0A;
    print("NullOS> ");

    current_color = 0x0F;
}

void execute_command()
{
    if(strcmp(command_buffer, "help"))
    {
        current_color = 0x0B;
        print("Commands: help clear about\n");
    }

    else if(strcmp(command_buffer, "about"))
    {
        current_color = 0x0E;
        print("NullOS Version 0.1\n");
    }

    else if(strcmp(command_buffer, "clear"))
    {
        clear_screen();
    }

    else
    {
        current_color = 0x0C;
        print("Unknown Command\n");
    }

    current_color = 0x0F;
}

/* =========================================
   KERNEL MAIN
========================================= */

void kernel_main()
{
    clear_screen();

    current_color = 0x0B;

    print("Welcome to NullOS!\n");
    print("Protected Mode Active\n");
    print("Keyboard Ready...\n\n");

    show_prompt();

    while(1)
    {
        char c = keyboard_read();

        if(c == 0)
            continue;

        if(c == 8)
        {
            if(buffer_index > 0)
            {
                buffer_index--;

                cursor_x--;

                print_char(' ');

                cursor_x--;

                update_cursor();
            }

            continue;
        }

        if(c == 13)
        {
            command_buffer[buffer_index] = 0;

            print_char('\n');

            execute_command();

            buffer_index = 0;

            show_prompt();

            continue;
        }

        command_buffer[buffer_index++] = c;

        current_color = 0x0F;

        print_char(c);
    }
}
