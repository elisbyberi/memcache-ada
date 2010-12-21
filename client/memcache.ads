--
--  Primary Ada Memcached client specification
--
--  This package defines the core API accessible by
--  users of this library
--

with Ada.Calendar;
with Ada.Containers.Vectors;
with Ada.Streams;
with Ada.Strings.Unbounded;
with GNAT.Sockets;

use Ada.Containers;

package Memcache is
    package Unbounded renames Ada.Strings.Unbounded;
    use type Unbounded.Unbounded_String;

    --
    --  When passing an expiration, it must be within this range
    --  otherwise the server will treat it as a unix timestamp
    type Expiration is range 0 .. 60*60*24*30;
    subtype Port_Type is GNAT.Sockets.Port_Type;
    type Flags_Type is mod 2 ** 16;

    type Response is record
        Flags : Flags_Type;
        Data : Unbounded.Unbounded_String;
    end record;

    type Connection is tagged private;

    function Get (This : in Connection; Key : in String)
                return Response;

    function Set (This : in Connection;
                    Key : in String;
                    Value : in String;
                    Flags  : in Flags_Type := 0;
                    Expire : in Expiration := 0)
                return Boolean;

    procedure Set (This : in Connection;
                    Key : in String;
                    Value : in String;
                    Flags : in Flags_Type := 0;
                    Expire : in Expiration := 0);

    function Set (This : in Connection;
                    Key : in String;
                    Value : in String;
                    Flags : in Flags_Type := 0;
                    Expire : in Ada.Calendar.Time)
                return Boolean;

    --
    --  Functions/procedures implementing the "delete" memcached
    --  command
    function Delete (This : in Connection; Key : in String;
                    Delayed : in Expiration := 0)
                return Boolean;

    function Delete (This : in Connection; Key : in String;
                    Delayed : in Ada.Calendar.Time)
                return Boolean;

    procedure Delete (This : in Connection; Key : in String;
                    Delayed : in Expiration := 0);

    procedure Delete (This : in Connection; Key : in String;
                    Delayed : in Ada.Calendar.Time);
    --
    --


    --
    --  Functions/procedures implementing the "incr" memcached
    --  command
    function Increment (This : in Connection; Key : in String;
                    Value : in Natural)
                return Boolean;
    procedure Increment (This : in Connection; Key : in String;
                    Value : in Natural);
    --
    --


    --
    --  Functions/procedures implementing the "decr" memcached
    --  command
    function Decrement (This : in Connection; Key : in String;
                    Value : in Natural)
                return Boolean;
    procedure Decrement (This : in Connection; Key : in String;
                    Value : in Natural);
    --
    --


    --
    --  Stats from the memcached server come back in a relatively
    --  unstructured format, so this function will just dump to stdout
    procedure Dump_Stats (This : in Connection);

    function Create (Host : in String; Port : in Port_Type)
                return Connection;

    procedure Connect (Conn : in out Connection);
    procedure Disconnect (Conn : in out Connection);

    --
    --  Memcache client exceptions
    Invalid_Key_Error : exception;
    Unexpected_Response : exception;
    Invalid_Connection : exception;
    Not_Implemented : exception;
    Not_Connected : exception;

private

    Response_Stored : constant String := "STORED";
    Response_Deleted : constant String := "DELETED";
    Response_Not_Found : constant String := "NOT_FOUND";

    type Connection is tagged record
        Sock : GNAT.Sockets.Socket_Type;
        Address : GNAT.Sockets.Sock_Addr_Type;
        Connected : Boolean := False;
    end record;


    --
    --  Validation functionsto ensure that a few basic
    --  conditions are met:
    --      * No spaces in keys
    --      * Key length is less than or equal to 250 characters
    --      * Key length is greater than zero characters
    procedure Validate (Key : in String);

    procedure Is_Connected (C : in Connection);


    --
    --  Generation functions, used to generate the actual text
    --  representations of commands to be sent over the wire to
    --  the memcached server
    function Generate_Delete (Key : in String;
                                Delayed : in Expiration;
                                No_Reply : in Boolean) return String;
    function Generate_Delete (Key : in String;
                                Delayed : in Ada.Calendar.Time;
                                No_Reply : in Boolean) return String;

    function Generate_Incr (Key : in String; Value : in Natural;
                                No_Reply : in Boolean) return String;

    function Generate_Decr (Key : in String; Value : in Natural;
                                No_Reply : in Boolean) return String;

    function Generate_Set (Key : in String; Value : in String;
                                Flags : in Flags_Type;
                                Expire : in Expiration;
                                No_Reply : in Boolean) return String;

    function Generate_Get (Key : in String) return String;

    procedure Write_Command (Conn : in Connection; Command : in String);
    function Read_Until (Conn : in Connection; Terminator : in String;
                    Trim_CRLF : in Boolean := True)
                return String;
    function Read_Response (Conn : in Connection) return String;
    function Read_Get_Response (Conn : in Connection) return Response;

    function Contains_String (Haystack : in Unbounded.Unbounded_String;
                    Needle : in String) return Boolean;
    function Append_CRLF (Input : in String) return String;

end Memcache;
