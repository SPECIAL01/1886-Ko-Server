#include "stdafx.h"
#include "DBAgent.h"

using std::string;
using std::vector;

void CUser::SendBifrostTime(bool bSendAll) {
	Packet result(WIZ_BIFROST,uint8(2));
	result << g_pMain->m_sBifrostRemainingTime;

	if (bSendAll)
		g_pMain->Send_All(&result,nullptr, 0, ZONE_RONARK_LAND);
	else
		Send(&result);
}

void CUser::BifrostProcess(CUser * pUser)
{
	if (pUser == nullptr)
		return;

	if (g_pMain->m_BifrostVictory == 0 && g_pMain->m_bAttackBifrostMonument)
	{
		g_pMain->m_sBifrostTime = g_pMain->m_xBifrostTime;
		g_pMain->m_sBifrostRemainingTime = g_pMain->m_sBifrostTime;
		g_pMain->m_BifrostVictory = pUser->GetNation();
		g_pMain->SendFormattedResource(pUser->GetNation() == ELMORAD ? IDS_BEEF_ROAST_VICTORY_ELMORAD : IDS_BEEF_ROAST_VICTORY_KARUS, Nation::ALL,false);
		pUser->SendBifrostTime(true);

		if (g_pMain->m_bAttackBifrostMonument)
			g_pMain->m_bAttackBifrostMonument = false;
	}
	else if (g_pMain->m_BifrostVictory == 1 || g_pMain->m_BifrostVictory == 2) 
	{
		if (pUser->GetNation() != g_pMain->m_BifrostVictory && g_pMain->m_bAttackBifrostMonument)
		{
			g_pMain->m_BifrostVictory = 3;
			g_pMain->SendFormattedResource(pUser->GetNation() == ELMORAD ? IDS_BEEF_ROAST_VICTORY_ELMORAD : IDS_BEEF_ROAST_VICTORY_KARUS, Nation::ALL,false);

			if (g_pMain->m_bAttackBifrostMonument)
				g_pMain->m_bAttackBifrostMonument = false;
		}
	}
}

void CUser::TempleProcess(Packet &pkt )
{
	uint8 opcode = pkt.read<uint8>();

	switch(opcode)
	{
	case MONSTER_STONE:
		MonsterStoneProcess(); 
	case TEMPLE_JOIN:
		TempleJoin();
		break;
	case TEMPLE_DISBAND:
		TempleDisband();
		break;
	}
}

void CUser::MonsterStoneProcess()
{


} 

void CUser::TempleJoin()
{
	uint8 bResult = 1;
	uint16 Active = g_pMain->pTempleEvent.ActiveEvent;
	Packet result(WIZ_EVENT);
	result << uint8(TEMPLE_JOIN) << bResult << uint16(Active);

	if(GetZoneID() >= ZONE_JURAD_MOUNTAIN) {
		bResult = 0;
		result.put(0, bResult);
		Send(&result);
		return;
	}

	if(g_pMain->pTempleEvent.ActiveEvent == 24)
	{
		if (CheckExistItem(910246000,1))
			bResult = 1;
		else if (m_sItemArray[RIGHTHAND].nNum == MATTOCK || m_sItemArray[RIGHTHAND].nNum == GOLDEN_MATTOCK || isMining())
			bResult = 4; 
		else
			bResult = 3;
	}

	if(bResult != 1)
	{
		result.put(0, bResult);
		Send(&result);
		return;
	}

	if(isTempleJoin()){
		Send(&result);
		setTempleJoin();
	}
	else
		return;

	if(GetNation() == KARUS)
		g_pMain->pTempleEvent.KarusUserCount++;
	else if (GetNation() == ELMORAD)
		g_pMain->pTempleEvent.ElMoradUserCount++;

	g_pMain->pTempleEvent.AllUserCount = g_pMain->pTempleEvent.KarusUserCount + g_pMain->pTempleEvent.ElMoradUserCount;

	SendTempleCounterPacket();     
}

void CUser::TempleDisband()
{
	uint8 bResult = 1;
	uint16 Active = g_pMain->pTempleEvent.ActiveEvent;
	Packet result(WIZ_EVENT);
	result << uint8(TEMPLE_DISBAND) << bResult << uint16(Active);

	if(!isTempleJoin())
	{
		Send(&result);
		if(GetNation() == KARUS)
			g_pMain->pTempleEvent.KarusUserCount--;
		else if (GetNation() == ELMORAD)
			g_pMain->pTempleEvent.ElMoradUserCount--;

		setTempleJoin();
		g_pMain->pTempleEvent.AllUserCount = g_pMain->pTempleEvent.KarusUserCount + g_pMain->pTempleEvent.ElMoradUserCount;
	}

	SendTempleCounterPacket();
}

void CUser::SendTempleCounterPacket()
{
	Packet result(WIZ_EVENT);
	result << uint8(TEMPLE_COUNTER) << uint16(g_pMain->pTempleEvent.ActiveEvent);

	if(g_pMain->pTempleEvent.ActiveEvent == 24)
		result << uint16(g_pMain->pTempleEvent.AllUserCount);
	else
		result << uint16(g_pMain->pTempleEvent.KarusUserCount) << uint16(g_pMain->pTempleEvent.ElMoradUserCount);

	g_pMain->Send_All(&result);
}