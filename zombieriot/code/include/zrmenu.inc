#if defined _zrmenu_included
  #endinput
#endif
#define _zrmenu_included

#include <zrconst>

//��M�˵�����ע��һ����ѡ��(menunameΪѡ������,ע���᷵��һ���˵�����ID,��zr_addmenu_event����õ���)
native zr_register_menu(const menuname[])

//Post�¼�:M�˵�������ѡ����¼�(��zr_register_menuע��Ĳ˵��������ﴥ��,MenuID���������ص�ID��)
forward zr_addmenu_event(iPlayer, MenuID)

//Pre�¼�:M�˵���menu_additem�����¼�(��Ϻ�����Լ���menu_additem���¹���)
forward zr_hook_menudata(MenuID, const MenuName[], const MenuInfo[])