--
--  Test executable to create a connection, execute a `delete`
--  command and then disconnect.
--

with Ada.Command_Line;
with Memcache;

procedure Deleter is
    Port : String := Ada.Command_Line.Argument (1);
    C : Memcache.Connection :=
            Memcache.Create (Host => "127.0.0.1",
                            Port => Memcache.Port_Type'Value (Port));
begin
    C.Connect;
    C.Delete ("deleter");
    C.Disconnect;
end Deleter;
