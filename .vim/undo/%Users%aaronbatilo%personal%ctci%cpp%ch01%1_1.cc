Vim�UnDo� r"i3�+�7c�@D��
Cy�K;cQ+�[                      I       I   I   I    WLx�    _�                             ����                                                                                                                                                                                                                                                                                                                                                             WLv�     �             5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLv�    �                �             5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLv�     �                 5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLv�     �                 �             5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLv�     �                using std::string;5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLv�     �                 5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             WLv�    �                 string5�_�      	                     ����                                                                                                                                                                                                                                                                                                                                                             WLv�     �                 std::string5�_�      
           	          ����                                                                                                                                                                                                                                                                                                                                                             WLv�     �                  std::string test2 = "carrace5�_�   	              
           ����                                                                                                                                                                                                                                                                                                                                                             WLv�     �             5�_�   
                         ����                                                                                                                                                                                                                                                                                                                                                             WLv�     �                 5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLv�     �                 �             5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLv�     �                �             5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             WLw     �               bool isUnique(std::string input5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLw    �                bool isUnique(std::string &input5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLw    �             5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             WLw@     �               &   * Notes for before we start solving5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             WLwC    �                  * 5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLwc     �                 "// Pre-solve assumptions/questions5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             WLwc     �                   /*5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             WLwd     �                 E   * I'm making the assumption that we're only working with lowercase5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             WLwd     �                    * alphabet5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             WLwd     �                    */5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLwd     �                  5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLwd     �                 // Pre-solve/pre-check notes5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             WLwd     �                   /*5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             WLwd     �                 +   * Notes for before checking the solution5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             WLwd     �                    */5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLwd     �                  5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLwe     �                 // Post-solve/post-check notes5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             WLwe     �                   /*5�_�      !                      ����                                                                                                                                                                                                                                                                                                                                                             WLwe     �                 &   * Notes after checking the solution5�_�       "           !          ����                                                                                                                                                                                                                                                                                                                                                             WLwe     �                    */5�_�   !   #           "           ����                                                                                                                                                                                                                                                                                                                                                             WLwe    �                  5�_�   "   $           #           ����                                                                                                                                                                                                                                                                                                                                                             WLwi     �                 5�_�   #   %           $           ����                                                                                                                                                                                                                                                                                                                                                             WLwi    �                 �             5�_�   $   &           %           ����                                                                                                                                                                                                                                                                                                                                                             WLwt     �                 5�_�   %   '           &           ����                                                                                                                                                                                                                                                                                                                                                             WLwt   	 �                 �             5�_�   &   (           '           ����                                                                                                                                                                                                                                                                                                                                                             WLw�   
 �      
           �             5�_�   '   )           (           ����                                                                                                                                                                                                                                                                                                                                                             WLw�     �                 5�_�   (   *           )           ����                                                                                                                                                                                                                                                                                                                                                             WLw�    �      	             �      	       5�_�   )   +           *           ����                                                                                                                                                                                                                                                                                                                                                             WLw�     �                 5�_�   *   ,           +           ����                                                                                                                                                                                                                                                                                                                                                             WLw�     �                 �             5�_�   +   -           ,          ����                                                                                                                                                                                                                                                                                                                                                             WLw�    �                 isUnique(test1)5�_�   ,   .           -          ����                                                                                                                                                                                                                                                                                                                                                             WLw�     �               "  for (int i = 0; i < seen; ++i) {5�_�   -   /           .          ����                                                                                                                                                                                                                                                                                                                                                             WLw�    �                 for (int i = 0; i < ; ++i) {5�_�   .   0           /          ����                                                                                                                                                                                                                                                                                                                                                             WLw�    �                 bool seen[255];5�_�   /   1           0          ����                                                                                                                                                                                                                                                                                                                                                             WLw�     �                 bool seen[255] = 0;5�_�   0   2           1          ����                                                                                                                                                                                                                                                                                                                                                             WLw�    �                 bool seen[255] = { 0;5�_�   1   3           2           ����                                                                                                                                                                                                                                                                                                                                                             WLw�     �      	             �      	       5�_�   2   4           3          ����                                                                                                                                                                                                                                                                                                                                                             WLw�    �                    5�_�   3   5           4          ����                                                                                                                                                                                                                                                                                                                                                             WLw�     �               !  for (int i = 0; i < 255; ++i) {5�_�   4   6           5          ����                                                                                                                                                                                                                                                                                                                                                             WLx      �                 for (int i = 0; i < ; ++i) {5�_�   5   7           6          ����                                                                                                                                                                                                                                                                                                                                                             WLx    �               #  for (int i = 0; i < input; ++i) {5�_�   6   8           7          ����                                                                                                                                                                                                                                                                                                                                                             WLx	     �                    printf("%d\n", seen[i]);5�_�   7   9           8           ����                                                                                                                                                                                                                                                                                                                                                             WLx	     �      	       5�_�   8   :           9   
   	    ����                                                                                                                                                                                                                                                                                                                                                             WLx     �   	              return false;5�_�   9   ;           :   
   	    ����                                                                                                                                                                                                                                                                                                                                                             WLx    �   	            
  return ;5�_�   :   <           ;           ����                                                                                                                                                                                                                                                                                                                                                             WLx     �                 5�_�   ;   =           <           ����                                                                                                                                                                                                                                                                                                                                                             WLx    �                   �      	       5�_�   <   >           =          ����                                                                                                                                                                                                                                                                                                                                                             WLxD     �                 isUnique(test1);5�_�   =   ?           >      
    ����                                                                                                                                                                                                                                                                                                                                                             WLxM    �               !  printf("%s\n", isUnique(test1);5�_�   >   @           ?      ,    ����                                                                                                                                                                                                                                                                                                                                                             WLxY     �               -  printf("isUnique(): %s\n", isUnique(test1);5�_�   ?   A           @      ,    ����                                                                                                                                                                                                                                                                                                                                                             WLxZ    �               ,  printf("isUnique(): %s\n", isUnique(test1)5�_�   @   B           A          ����                                                                                                                                                                                                                                                                                                                                                             WLxk     �                  std::string test1 = "racecar";5�_�   A   C           B          ����                                                                                                                                                                                                                                                                                                                                                             WLxl    �                 std::string test1 = "";5�_�   B   D           C          ����                                                                                                                                                                                                                                                                                                                                                             WLxu     �                 std::string test1 = "bo";5�_�   C   E           D      	    ����                                                                                                                                                                                                                                                                                                                                                             WLxx    �               int main() {5�_�   D   F           E          ����                                                                                                                                                                                                                                                                                                                                                             WLx�    �                 std::string test1 = 5�_�   E   G           F           ����                                                                                                                                                                                                                                                                                                                                                             WLx�    �                 �             5�_�   F   H           G           ����                                                                                                                                                                                                                                                                                                                                                             WLx�     �                 5�_�   G   I           H           ����                                                                                                                                                                                                                                                                                                                                                             WLx�    �                   �             5�_�   H               I           ����                                                                                                                                                                                                                                                                                                                                                             WLx�    �                   �             5��