int mode13h_graphics_init(void);
int mode13h_graphics_update(void);
void set_vga_pal(void);
int graphics_input(void);
void write_framebuffer(int address, int value);

/* TIC-80 compat */
void pix(int x, int y, int color);
