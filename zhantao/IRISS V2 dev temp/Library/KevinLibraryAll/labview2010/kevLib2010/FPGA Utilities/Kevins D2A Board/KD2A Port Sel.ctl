RSRC
 LVCCLBVW  y$        y      kevLib2010.lvlib      � �            < � @�      ����            ���g1�D�U�=% #          �WK�M?K�h,�rH�ċ���\:���8�*4       ������M�k6���%                           *��)��n?Va�e��6=   c LVCC"kevLib2010.lvlib:KD2A Port Sel.ctl       VILB      PTH0         kevLib2010.lvlib                 
x�c`f````   � 7        �x�c`��%4���,@�
 A�    2 VIDS"kevLib2010.lvlib:KD2A Port Sel.ctl              �   10.0     �   10.0     �   10.0     �   10.0     �   10.0    ������  �  �u"�E"��e"�B"��r:�  �  �  �����  �  �  �?�� �
 A���a���q���a� A�A	�A�A	�  	�  	�  	�  	�  �  ����   �����������������33333333333333?�33333333333333?�3�??�??3�3���3?�3��?3??3�3��?3?�3�3?�??3�3���3?�3��?33�3�3��?3?�3�??�3�3�����3?�33333333333333?�33333333333333?�33333333333333?�����������������              �              �     ���      �    ����      �    �̙�      � �  ��      ����������� ������������� ������������ � �   ��      �        ��        ��         ��             ��             ��             ��             ��            ��              ����������������   ������������������������������������������������������������������������������������������������������������������������������������������                              ��                              ��          ++++++              ��        �������+              ��        �uuuv�V               ��  �      VJtu��        �      �� �� ������&u���������� ��     ��+�� ������PJ���������� ��+    �� +� �������������Ь��� �+     ��  +       +���         +      ��   V     V V   V     V     �  ��   �     �     �     �    ��  ��   �     �     �     V     �  ��                           �  ��                           �  ��                           �  ��                           �  ��                          ��� ��                              ���������������������������������         2 FPHP"kevLib2010.lvlib:KD2A Port Sel.ctl            � �                displayFilter �                    tdData �                IOInterface �     @0����data type XML string      <Interface>
<MethodSet>
   <Method name="Read">
      <AttributeSet>
         <Attribute name="NumberOfSyncRegistersForRead">
            <LocalizedName localize="true">Number of Synchronizing Registers for Read</LocalizedName>
            <LocalizedValues localize="true">Inherit From Project Item,Auto,0,1,2</LocalizedValues>
            <SupportedValues>InheritFromProjectItem,Auto,0,1,2</SupportedValues>
         </Attribute>
      </AttributeSet>
      <LocalizedName localize="true">Read</LocalizedName>
      <ReturnValue>
         <Type>bool</Type>
      </ReturnValue>
   </Method>
   <Method name="Set Output Data">
      <LocalizedName localize="true">Set Output Data</LocalizedName>
      <ParameterList>
         <Parameter name="Data">
            <Direction>in</Direction>
            <LocalizedName localize="true">Data</LocalizedName>
            <Required>yes</Required>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Set Output Enable">
      <LocalizedName localize="true">Set Output Enable</LocalizedName>
      <ParameterList>
         <Parameter name="Enable">
            <Direction>in</Direction>
            <LocalizedName localize="true">Enable</LocalizedName>
            <Required>yes</Required>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Any Edge">
      <LocalizedName localize="true">Wait on Any Edge</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Falling Edge">
      <LocalizedName localize="true">Wait on Falling Edge</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on High Level">
      <LocalizedName localize="true">Wait on High Level</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Low Level">
      <LocalizedName localize="true">Wait on Low Level</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Rising Edge">
      <LocalizedName localize="true">Wait on Rising Edge</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Write">
      <LocalizedName localize="true">Write</LocalizedName>
      <ParameterList>
         <Parameter name="Value">
            <LocalizedName localize="true">Value</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
   </Method>
</MethodSet></Interface>       	typeClass �      0����      FPGA I/O        � �                displayFilter �                    tdData �                IOInterface �     @0����data type XML string      <Interface>
<MethodSet>
   <Method name="Read">
      <AttributeSet>
         <Attribute name="NumberOfSyncRegistersForRead">
            <LocalizedName localize="true">Number of Synchronizing Registers for Read</LocalizedName>
            <LocalizedValues localize="true">Inherit From Project Item,Auto,0,1,2</LocalizedValues>
            <SupportedValues>InheritFromProjectItem,Auto,0,1,2</SupportedValues>
         </Attribute>
      </AttributeSet>
      <LocalizedName localize="true">Read</LocalizedName>
      <ReturnValue>
         <Type>bool</Type>
      </ReturnValue>
   </Method>
   <Method name="Set Output Data">
      <LocalizedName localize="true">Set Output Data</LocalizedName>
      <ParameterList>
         <Parameter name="Data">
            <Direction>in</Direction>
            <LocalizedName localize="true">Data</LocalizedName>
            <Required>yes</Required>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Set Output Enable">
      <LocalizedName localize="true">Set Output Enable</LocalizedName>
      <ParameterList>
         <Parameter name="Enable">
            <Direction>in</Direction>
            <LocalizedName localize="true">Enable</LocalizedName>
            <Required>yes</Required>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Any Edge">
      <LocalizedName localize="true">Wait on Any Edge</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Falling Edge">
      <LocalizedName localize="true">Wait on Falling Edge</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on High Level">
      <LocalizedName localize="true">Wait on High Level</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Low Level">
      <LocalizedName localize="true">Wait on Low Level</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Rising Edge">
      <LocalizedName localize="true">Wait on Rising Edge</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Write">
      <LocalizedName localize="true">Write</LocalizedName>
      <ParameterList>
         <Parameter name="Value">
            <LocalizedName localize="true">Value</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
   </Method>
</MethodSet></Interface>       	typeClass �      0����      FPGA I/O        � �                displayFilter �                    tdData �                IOInterface �     @0����data type XML string      <Interface>
<MethodSet>
   <Method name="Read">
      <AttributeSet>
         <Attribute name="NumberOfSyncRegistersForRead">
            <LocalizedName localize="true">Number of Synchronizing Registers for Read</LocalizedName>
            <LocalizedValues localize="true">Inherit From Project Item,Auto,0,1,2</LocalizedValues>
            <SupportedValues>InheritFromProjectItem,Auto,0,1,2</SupportedValues>
         </Attribute>
      </AttributeSet>
      <LocalizedName localize="true">Read</LocalizedName>
      <ReturnValue>
         <Type>bool</Type>
      </ReturnValue>
   </Method>
   <Method name="Set Output Data">
      <LocalizedName localize="true">Set Output Data</LocalizedName>
      <ParameterList>
         <Parameter name="Data">
            <Direction>in</Direction>
            <LocalizedName localize="true">Data</LocalizedName>
            <Required>yes</Required>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Set Output Enable">
      <LocalizedName localize="true">Set Output Enable</LocalizedName>
      <ParameterList>
         <Parameter name="Enable">
            <Direction>in</Direction>
            <LocalizedName localize="true">Enable</LocalizedName>
            <Required>yes</Required>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Any Edge">
      <LocalizedName localize="true">Wait on Any Edge</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Falling Edge">
      <LocalizedName localize="true">Wait on Falling Edge</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on High Level">
      <LocalizedName localize="true">Wait on High Level</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Low Level">
      <LocalizedName localize="true">Wait on Low Level</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Rising Edge">
      <LocalizedName localize="true">Wait on Rising Edge</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Write">
      <LocalizedName localize="true">Write</LocalizedName>
      <ParameterList>
         <Parameter name="Value">
            <LocalizedName localize="true">Value</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
   </Method>
</MethodSet></Interface>       	typeClass �      0����      FPGA I/O        � �                displayFilter �                    tdData �                IOInterface �     @0����data type XML string      <Interface>
<MethodSet>
   <Method name="Read">
      <AttributeSet>
         <Attribute name="NumberOfSyncRegistersForRead">
            <LocalizedName localize="true">Number of Synchronizing Registers for Read</LocalizedName>
            <LocalizedValues localize="true">Inherit From Project Item,Auto,0,1,2</LocalizedValues>
            <SupportedValues>InheritFromProjectItem,Auto,0,1,2</SupportedValues>
         </Attribute>
      </AttributeSet>
      <LocalizedName localize="true">Read</LocalizedName>
      <ReturnValue>
         <Type>bool</Type>
      </ReturnValue>
   </Method>
   <Method name="Set Output Data">
      <LocalizedName localize="true">Set Output Data</LocalizedName>
      <ParameterList>
         <Parameter name="Data">
            <Direction>in</Direction>
            <LocalizedName localize="true">Data</LocalizedName>
            <Required>yes</Required>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Set Output Enable">
      <LocalizedName localize="true">Set Output Enable</LocalizedName>
      <ParameterList>
         <Parameter name="Enable">
            <Direction>in</Direction>
            <LocalizedName localize="true">Enable</LocalizedName>
            <Required>yes</Required>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Any Edge">
      <LocalizedName localize="true">Wait on Any Edge</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Falling Edge">
      <LocalizedName localize="true">Wait on Falling Edge</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on High Level">
      <LocalizedName localize="true">Wait on High Level</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Low Level">
      <LocalizedName localize="true">Wait on Low Level</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Wait on Rising Edge">
      <LocalizedName localize="true">Wait on Rising Edge</LocalizedName>
      <ParameterList>
         <Parameter name="Timeout">
            <Direction>in</Direction>
            <LocalizedName localize="true">Timeout</LocalizedName>
            <Required>yes</Required>
            <Type>I32</Type>
         </Parameter>
         <Parameter name="Timed Out">
            <Direction>out</Direction>
            <LocalizedName localize="true">Timed Out</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
      <ReturnValue>
         <Type>void</Type>
      </ReturnValue>
   </Method>
   <Method name="Write">
      <LocalizedName localize="true">Write</LocalizedName>
      <ParameterList>
         <Parameter name="Value">
            <LocalizedName localize="true">Value</LocalizedName>
            <Type>bool</Type>
         </Parameter>
      </ParameterList>
   </Method>
</MethodSet></Interface>       	typeClass �      0����      FPGA I/O          )x�͘_LU�ϝ��YXd*t��]�,�V*�`)`e�EiK�PZLԆ]-
���K���M���1m��A��<4�1�LT��b]�ObLԄ���x���β�]p�%,���p�s�=����,@I��ά�y���
B*��p`}�n�/�m^����_dV�N�!������t/ ��h�.���@��Z�yB����Na��
�"YeN	��"�n�좣���+YV��<3V��U�y��.xQ-��������fv��VH���`vv�yLQ��F=j�ݨjdngД�fX�>dh
���G��^��SQ��TPQ��1��T�i�)eg5�&Dq^n)t��P��,�I�<�������e�1�
CQ��4>�������*����[�l��b#�a�.q��}�;���Rd#U%b�q�$����p�H�4tws���k=9���E9�����BK0==���і֣�\��u� �W���U���UۏU��@/�w=O�h`ǲ�c�ґ��1.�nB{��\�x�@�=|PT+�'y&�7����ͦ��0��&2hZPs!�è�@͵�=|HT��&��$ONN&��5���,!1+�w�;�ʟ�3�}��M�vcS���yE_�)�7���@n�t0�>�l���b�e��Ǔz2���#/F}'bv���=p��#�XW��ѧuB��iq�wNB��Jx|���V}ߤ;X�78��g���F�B���*L��	�a�`�̺�(���G�HJ%����W�p������Oxia�=f��4��� �U�xv�g���?�(�t	_e�;�U�ɧ\J7_�4~6�F~U'^���̓ſ2(�5k9���/I���.�w�_/����Ȣ�m��f.�����@�����������ac�Z�����g	�����yfz�8O��3 8=��vv���*ѠNK�r_�uX>3~Y�_tu�ҹ�PX���=p/��~i���Xu���{��47b�#1S61mH�K�ļ�����KLkǓw���y?g�|p���"�|�=1eK��i��6�g1�\s=1y61u61$�)�����<�AbJ[��Y��k�o��Ɯ��t�yl��s {rfKNsr6���r�\�Ӗ�.N����Br8hXCӒ��:�0��I��]#N���=9pjk���&z�$�JCN�&��J Ǚ#r���`�]��˸�����)\P�������eZ�k���G�~�i?�����bk�W|;�͵sm�U|���2�*��&�N�#�TH3���q���	�      X   2 BDHP"kevLib2010.lvlib:KD2A Port Sel.ctl             b   rx�c``��`��P���I�+�!���YЏ�7���a �( 	����.��>��� �l���9�2-�����z�\�8Se�<� b           1      NI_IconEditor �      0����      10008000
      
NI_Library          �����������������������������������������������������������������������������������������������������������������������������������������                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        ��� ��� ��� ��f ��3 ��  ��� ��� �̙ ��f ��3 ��  ��� ��� ��� ��f ��3 ��  �f� �f� �f� �ff �f3 �f  �3� �3� �3� �3f �33 �3  � � � � � � � f � 3 �   ��� ��� ��� ��f ��3 ��  ��� ��� �̙ ��f ��3 ��  ̙� ̙� ̙� ̙f ̙3 ̙  �f� �f� �f� �ff �f3 �f  �3� �3� �3� �3f �33 �3  � � � � � � � f � 3 �   ��� ��� ��� ��f ��3 ��  ��� ��� �̙ ��f ��3 ��  ��� ��� ��� ��f ��3 ��  �f� �f� �f� �ff �f3 �f  �3� �3� �3� �3f �33 �3  � � � � � � � f � 3 �   f�� f�� f�� f�f f�3 f�  f�� f�� f̙ f�f f�3 f�  f�� f�� f�� f�f f�3 f�  ff� ff� ff� fff ff3 ff  f3� f3� f3� f3f f33 f3  f � f � f � f f f 3 f   3�� 3�� 3�� 3�f 3�3 3�  3�� 3�� 3̙ 3�f 3�3 3�  3�� 3�� 3�� 3�f 3�3 3�  3f� 3f� 3f� 3ff 3f3 3f  33� 33� 33� 33f 333 33  3 � 3 � 3 � 3 f 3 3 3    ��  ��  ��  �f  �3  �   ��  ��  ̙  �f  �3  �   ��  ��  ��  �f  �3  �   f�  f�  f�  ff  f3  f   3�  3�  3�  3f  33  3    �   �   �   f   3 �   �   �   �   �   w   U   D   "       �   �   �   �   �   w   U   D   "       �   �   �   �   �   w   U   D   "    ��� ��� ��� ��� ��� www UUU DDD """                       ������  �  �u"�E"��e"�B"��r:�  �  �  ����                                                                                        ���               NI_IconNumber          �                                                                                                                                ���                      �                                                                                                                                ���               VI Icon          ���������������������������������                              ��                              ��                              ��                              ��                              ��                              ��                              ��                              ��                              ��                              ��                              ��                              ��                              ��          ++++++              ��        �������+              ��        �uuuv�V               ��  �      VJtu��        �      �� �� ������&u���������� ��     ��+�� ������PJ���������� ��+    �� +� �������������Ь��� �+     ��  +       +���         +      ��   V     V V   V     V        ��   �     �     �     �        ��   �     �     �     V        ��                              ��                              ��                              ��                              ��                              ��                              ���������������������������������        ��� ��� ��� ��f ��3 ��  ��� ��� �̙ ��f ��3 ��  ��� ��� ��� ��f ��3 ��  �f� �f� �f� �ff �f3 �f  �3� �3� �3� �3f �33 �3  � � � � � � � f � 3 �   ��� ��� ��� ��f ��3 ��  ��� ��� �̙ ��f ��3 ��  ̙� ̙� ̙� ̙f ̙3 ̙  �f� �f� �f� �ff �f3 �f  �3� �3� �3� �3f �33 �3  � � � � � � � f � 3 �   ��� ��� ��� ��f ��3 ��  ��� ��� �̙ ��f ��3 ��  ��� ��� ��� ��f ��3 ��  �f� �f� �f� �ff �f3 �f  �3� �3� �3� �3f �33 �3  � � � � � � � f � 3 �   f�� f�� f�� f�f f�3 f�  f�� f�� f̙ f�f f�3 f�  f�� f�� f�� f�f f�3 f�  ff� ff� ff� fff ff3 ff  f3� f3� f3� f3f f33 f3  f � f � f � f f f 3 f   3�� 3�� 3�� 3�f 3�3 3�  3�� 3�� 3̙ 3�f 3�3 3�  3�� 3�� 3�� 3�f 3�3 3�  3f� 3f� 3f� 3ff 3f3 3f  33� 33� 33� 33f 333 33  3 � 3 � 3 � 3 f 3 3 3    ��  ��  ��  �f  �3  �   ��  ��  ̙  �f  �3  �   ��  ��  ��  �f  �3  �   f�  f�  f�  ff  f3  f   3�  3�  3�  3f  33  3    �   �   �   f   3 �   �   �   �   �   w   U   D   "       �   �   �   �   �   w   U   D   "       �   �   �   �   �   w   U   D   "    ��� ��� ��� ��� ��� www UUU DDD """                       ������  �  �  �  �  �  �  �  �  �  �  �  �  �  �?�� �
 A���a���q���a� A�A�A�A�  �  �  �  �  �  ����        ���                       
      �   (                                       �  "x��X�n�@�y5iREi��G,�B1!�nBj�
Q�6x�i�:��Ȫ��~A;c΢�m����s��ؖ ^�Ç?ꀝ#�	�؀m�
���*[LbѴ8t9��h�6�;8p>>6C�ܾ�	�6wjX��B����y��m'�=�Ky)�����ԭ۩cQn��Q�-�S�zE.&�l�7lJ�s����yJ
�r>�M��ڂ3�@X����Ҽ�1�4+�����(���X���wPE�o�!�%q'�w%Ogҧ��X�%��v�\�p5�Ԕ�#�(d��F�԰�ƴ�?��9�1�X��y��#��8W眚�w�������)�Q	��+��D[ک���f%^��2��KJ㩇A��j��a�1�������~w�����\`M:���ڰ�Q���=w�}N�x�x��:�+���=�H�g97��i�_m����� ]9���ŭ=�;��ܕ�1̀:�iZg�E�9�HG����]�N�}~���$�6�����,Ǳ�4i�,͏��F%��tYa���,Y�,����*C`"�D�1��Jz���Ǡ�0a�%LA��R��k���k�M.�̍5ix���Lc��ww���<��P��»=�2�޾�pm��#���L
N�jC��.K7ksԬk0��8(�G�W�긟��6��q�D���i��)���)d����4$��E����o
V9\��=�u�>8*�/x�����3���H=�q�`��R��	jK����A9K�   e       H      � �   Q      � �   Z      � �   c� � �   � �Segoe UISegoe UISegoe UI0   RSRC
 LVCCLBVW  y$        y               4     LIBN      <LVSR      PRTSG      dLIvi      xCONP      �TM80      �DFDS      �LIds      �vers     �ICON      @icl4      Ticl8      hCPC2      |LIfp      �STR      �FPHb      �FPSE      LIbd      BDHb      0BDSE      DVITS      XDTHP      lMUID      �HIST      �VCTP      �FTAB      �    ����                                   ����       �        ����       �        ����      <        ����      D        ����      `        ����      �       ����      �       ����      �       ����      �       	����      �       
����      �        ����              ����      �        ����      �        ����      �        ����      �       ����      �       ����      �       ����      2�       ����      G�        ����      \x        ����      a�        ����      a�        ����      a�        ����      b8        ����      b@        ����      ux        ����      u�        ����      u�        ����      u�       �����      x�    KD2A Port Sel.ctl