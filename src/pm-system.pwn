/*
 * @Title: SA:MP PM System
 * @Version: 1.0
 *
 * Copyright (c) 2025 Yuuki X
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and asso ciated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#define     FILTERSCRIPT

#include <open.mp>
#include <sscanf2>
#include <izcmd>

// Constants
const
    ERROR_COLOR   = 0xFF0000AA,    // Red
    SYNTAX_COLOR  = 0xC0C0C0AA,    // Grey
    SERVER_COLOR  = 0xFFFFFFAA,    // White
    PM_COLOR      = 0xFFDE21AA;    // Yellow

static
    PMSessions[MAX_PLAYERS];

// Global Functions
public OnFilterScriptInit()
{
    print("+---------------------------+");
    print("| PM System Loaded!         |");
    print("| By: Yuuki X               |");
    print("+---------------------------+");
    print("| Status:                   |");
    print("| SUCCESS: Script Inited!   |");
    print("+---------------------------+");
    return 1;
}

public OnFilterScriptExit()
{
    print("+---------------------------+");
    print("| PM System Loaded!         |");
    print("| By: Yuuki X               |");
    print("+---------------------------+");
    print("| Status:                   |");
    print("| SUCCESS: Unloaded!        |");
    print("+---------------------------+");
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new receiverid = PMSessions[playerid];

    // Make sure to check if the receiver still in the playerid session
    if (PMSessions[receiverid] == playerid)
    {
        // after that we reset session.
        PMSessions[receiverid] = INVALID_PLAYER_ID;
    }

    // Reset the receiver session as well.
    PMSessions[playerid] = INVALID_PLAYER_ID;
    return 1;
}

SendPMToPlayer(senderid, receiverid, const message[])
{
    // Create new sessions
    PMSessions[senderid] = receiverid;
    PMSessions[receiverid] = senderid;

    new
        playerName[MAX_PLAYER_NAME + 1],
        targetName[MAX_PLAYER_NAME + 1];

    GetPlayerName(senderid, playerName, MAX_PLAYER_NAME);
    GetPlayerName(receiverid, targetName, MAX_PLAYER_NAME);

    if (strlen(message) > 64)
    {
        SendClientMessageEx(receiverid, PM_COLOR, "(( PM from %s: %64s", playerName, message);
        SendClientMessageEx(receiverid, PM_COLOR, "...%s ))", message[64]);

        SendClientMessageEx(senderid, PM_COLOR, "(( PM to %s: %64s ))", targetName, message);
        SendClientMessageEx(senderid, PM_COLOR, "...%s ))", message[64]);
    }
    else
    {
        SendClientMessageEx(receiverid, PM_COLOR, "(( PM from %s: %s ))", playerName, message);
        SendClientMessageEx(senderid, PM_COLOR, "(( PM to %s: %s ))", targetName, message);
    }
    return 1;
}

// Commands
CMD:pm(playerid, const params[])
{
    // Provide 2 option for /pm system
    new option, targetid, text[128 + 1];
    if (sscanf(params, "rs[128]|s[128]", option, targetid, text))
    {
        // If not in any sessions
        if (!IsPlayerConnected(PMSessions[playerid]))
        {
            SendClientMessage(playerid, SYNTAX_COLOR, "USAGE:{FFFFFF} /pm <playerid/PartOfName> <text>");
        }
        else // but if any
        {
            SendClientMessage(playerid, SYNTAX_COLOR, "USAGE:{FFFFFF} /pm [playerid/PartOfName] <text>");
        }
        return 1;
    }

    // If the player choose option 2
    if (option == 2)
    {
        SendPMToPlayer(playerid, PMSessions[playerid], text);
        return 1;
    }

    // But if player typed the targetid/name
    if (targetid == INVALID_PLAYER_ID)
    {
        SendClientMessage(playerid, ERROR_COLOR, "ERROR:{FFFFFF} Invalid player specified!");
        return 1;
    }

    // Send it here
    SendPMToPlayer(playerid, targetid, text);
    return 1;
}

static SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
    static args, str[144];

    if ((args = numargs()) == 3)
    {
        SendClientMessage(playerid, color, text);
    }
    else
    {
        while (--args >= 3)
        {
            #emit LCTRL 5
            #emit LOAD.alt args
            #emit SHL.C.alt 2
            #emit ADD.C 12
            #emit ADD
            #emit LOAD.I
            #emit PUSH.pri
        }

        #emit PUSH.S text   // 0
        #emit PUSH.C 144    // 4
        #emit PUSH.C str    // 8
        #emit PUSH.S 8
        #emit SYSREQ.C format
        #emit LCTRL 5
        #emit SCTRL 4

        SendClientMessage(playerid, color, str);
        #emit RETN
    }
    return 1;
}
