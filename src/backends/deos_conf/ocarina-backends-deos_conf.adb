------------------------------------------------------------------------------
--                                                                          --
--                           OCARINA COMPONENTS                             --
--                                                                          --
--           O C A R I N A . B A C K E N D S . D E O S _ C O N F            --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                   Copyright (C) 2014-2018 ESA & ISAE.                    --
--                                                                          --
-- Ocarina  is free software; you can redistribute it and/or modify under   --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion. Ocarina is distributed in the hope that it will be useful, but     --
-- WITHOUT ANY WARRANTY; without even the implied warranty of               --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
--                 Ocarina is maintained by the TASTE project               --
--                      (taste-users@lists.tuxfamily.org)                   --
--                                                                          --
------------------------------------------------------------------------------

with Ocarina.Instances;
with Ocarina.Backends.Messages;
with Ocarina.Backends.Expander;
with Ocarina.Backends.XML_Tree.Nodes;
with Ocarina.Backends.XML_Tree.Nutils;
with Ocarina.Backends.XML_Tree.Generator;
with Ocarina.Backends.Deos_Conf.Hm;
with Ocarina.Backends.Deos_Conf.Schedule;
with Ocarina.Backends.Deos_Conf.Naming;
with Ocarina.Backends.Deos_Conf.Partitions;
with Ocarina.Backends.Utils;

with Ocarina.Namet; use Ocarina.Namet;

package body Ocarina.Backends.Deos_Conf is

   use Ocarina.Instances;
   use Ocarina.Backends.Expander;
   use Ocarina.Backends.Messages;
   use Ocarina.Backends.Utils;

   package XTN renames Ocarina.Backends.XML_Tree.Nodes;
   package XTU renames Ocarina.Backends.XML_Tree.Nutils;

   --------------
   -- Generate --
   --------------

   procedure Generate (AADL_Root : Node_Id) is
      Instance_Root : Node_Id;
   begin

      Instance_Root := Instantiate_Model (AADL_Root);

      Expand (Instance_Root);

      Visit_Architecture_Instance (Instance_Root);
      --  Abort if the construction of the tree failed

      if No (XML_Root) then
         Display_Error ("Deos configuration generation failed", Fatal => True);
      end if;

      --  At this point, we have a valid tree, we can begin the XML
      --  file generation.

      --  Enter the output directory

      Enter_Directory (Generated_Sources_Directory);

      if not Remove_Generated_Sources then
         --  Create the source files

         XML_Tree.Generator.Generate (XML_Root);

      end if;

      --  Leave the output directory
      Leave_Directory;
   end Generate;

   ----------
   -- Init --
   ----------

   procedure Init is
   begin
      Register_Backend ("Deos_Conf", Generate'Access, Deos_XML);
   end Init;

   -----------
   -- Reset --
   -----------

   procedure Reset is
   begin
      null;
   end Reset;

   ---------------------------------
   -- Visit_Architecture_Instance --
   ---------------------------------

   procedure Visit_Architecture_Instance (E : Node_Id) is
   begin
      XML_Root := XTU.New_Node (XTN.K_HI_Distributed_Application);
      Set_Str_To_Name_Buffer ("generated-code");
      XTN.Set_Name (XML_Root, Name_Find);
      XTN.Set_Units (XML_Root, XTU.New_List (XTN.K_List_Id));
      XTN.Set_HI_Nodes (XML_Root, XTU.New_List (XTN.K_List_Id));

      XTU.Push_Entity (XML_Root);

      Deos_Conf.Naming.Visit (E);
      Deos_Conf.Partitions.Visit (E);
      Deos_Conf.Schedule.Visit (E);
      Deos_Conf.Hm.Visit (E);

      XTU.Pop_Entity;

   end Visit_Architecture_Instance;

   ------------------
   -- Get_XML_Root --
   ------------------

   function Get_XML_Root return Node_Id is
   begin
      return XML_Root;
   end Get_XML_Root;

end Ocarina.Backends.Deos_Conf;
