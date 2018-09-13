#if defined _zrmenu_included
  #endinput
#endif
#define _zrmenu_included

#include <zrconst>

//给M菜单里面注册一个子选项(menuname为选项名称,注册后会返回一个菜单子项ID,在zr_addmenu_event里会用得上)
native zr_register_menu(const menuname[])

//Post事件:M菜单新增子选项触发事件(用zr_register_menu注册的菜单会在这里触发,MenuID是它所返回的ID号)
forward zr_addmenu_event(iPlayer, MenuID)

//Pre事件:M菜单的menu_additem触发事件(打断后可以自己用menu_additem重新构建)
forward zr_hook_menudata(MenuID, const MenuName[], const MenuInfo[])