--
--
with Ada.Characters.Handling;
with Ada.Streams.Stream_IO;
with Ada.Strings.Fixed;
with Ada.Text_IO;
with GNAT.Sockets;

use Ada.Strings;
use type Ada.Streams.Stream_Element_Count;

package body Memcache is
    function Create (Host : in String; Port : in GNAT.Sockets.Port_Type)
                return Connection is
        C : Connection;
    begin
        C.Address.Addr := GNAT.Sockets.Inet_Addr (Host);
        C.Address.Port := Port;
        return C;
    end Create;

    procedure Connect (Conn : in out Connection) is
        use GNAT.Sockets;
    begin
        if Conn.Connected then
            return;
        end if;

        Initialize;
        Create_Socket (Conn.Sock);
        Set_Socket_Option (Conn.Sock, Socket_Level, (Reuse_Address, True));
        Connect_Socket (Conn.Sock, Conn.Address);
        Conn.Connected := True;
    end Connect;

    procedure Disconnect (Conn : in out Connection) is
    begin
        GNAT.Sockets.Close_Socket (Conn.Sock);
        Conn.Connected := False;
    end Disconnect;

    function Get (This : in Connection; Key : in String)
                return Unbounded.Unbounded_String is
    begin
        raise Not_Implemented;
        return Unbounded.To_Unbounded_String ("");
    end Get;

    function Set (This : in Connection;
                    Key : in String;
                    Set_Flags : in Flags := 0;
                    Expire : in Expiration := 0;
                    Value : in String)
                return Boolean is
    begin
        raise Not_Implemented;
        return False;
    end Set;

    function Set (This : in Connection;
                    Key : in String;
                    Set_Flags : in Flags := 0;
                    Expire : in Ada.Calendar.Time;
                    Value : in String)
                return Boolean is
    begin
        raise Not_Implemented;
        return False;
    end Set;


    function Delete (This : in Connection; Key : in String;
                    Delayed : in Expiration := 0)
                return Boolean is
    begin
        raise Not_Implemented;
        return False;
    end Delete;

    function Delete (This : in Connection; Key : in String;
                    Delayed : in Ada.Calendar.Time)
                return Boolean is
    begin
        raise Not_Implemented;
        return False;
    end Delete;

    procedure Delete (This : in Connection; Key : in String;
                    Delayed : in Expiration := 0) is
    begin
        raise Not_Implemented;
    end Delete;

    procedure Delete (This : in Connection; Key : in String;
                    Delayed : in Ada.Calendar.Time) is
    begin
        raise Not_Implemented;
    end Delete;


    function Increment (This : in Connection; Key : in String;
                    Value : in Natural)
                return Boolean is
    begin
        raise Not_Implemented;
        return False;
    end Increment;

    procedure Increment (This : in Connection; Key : in String;
                    Value : in Natural) is
    begin
        raise Not_Implemented;
    end Increment;

    function Decrement (This : in Connection; Key : in String;
                    Value : in Natural)
                return Boolean is
    begin
        raise Not_Implemented;
        return False;
    end Decrement;

    procedure Decrement (This : in Connection; Key : in String;
                    Value : in Natural) is
    begin
        raise Not_Implemented;
    end Decrement;
    --
    --  Stats from the memcached server come back in a relatively
    --  unstructured format, so this function will just dump to stdout
    procedure Dump_Stats (This : in Connection) is
    begin
        raise Not_Implemented;
    end Dump_Stats;


    --
    --  Private functions/procedures
    --
    procedure Validate (Keys : in Key_Vectors.Vector) is
    begin
        raise Not_Implemented;
    end Validate;

    procedure Validate (Key : in String) is
    begin
        --  A key must be between 1 and 250 characters in length
        if Key'Length = 0  or Key'Length > 250 then
            raise Invalid_Key_Error;
        end if;

        --
        --  It's unfortunate that string scanning is apprently necessary,
        --  but we need to verify a few conditions for the string:
        --      * No whitespace
        --      * No control characters
        for Index in Key'Range loop
            declare
                Key_Ch : Character := Key (Index);
            begin
                if Character'Pos (Key_Ch) = 32 then
                    raise Invalid_Key_Error;
                end if;

                if Ada.Characters.Handling.Is_Control (Key_Ch) then
                    raise Invalid_Key_Error;
                end if;
            end;
        end loop;
    end Validate;

    function Generate_Delete (Key : in String;
                                Delayed : in Expiration;
                                No_Reply : in Boolean) return String is
        Command : Unbounded.Unbounded_String;
    begin
        Validate (Key);

        Command := Unbounded.To_Unbounded_String ("delete ");

        if Delayed = 0 then
            Unbounded.Append (Command,
                Unbounded.To_Unbounded_String (Key));
        else
            Unbounded.Append (Command,
                Unbounded.To_Unbounded_String (Key &
                                Expiration'Image (Delayed)));
        end if;

        if No_Reply then
            Unbounded.Append (Command,
                Unbounded.To_Unbounded_String (" noreply"));
        end if;

        return Unbounded.To_String (Command) & ASCII.CR & ASCII.LF;
    end Generate_Delete;

    function Generate_Delete (Key : in String;
                                Delayed : in Ada.Calendar.Time;
                                No_Reply : in Boolean) return String is
    begin
        Validate (Key);
        return  "";
    end Generate_Delete;
end Memcache;

