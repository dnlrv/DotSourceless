class NPC
{
	[System.String]$Name

	NPC () {}

	NPC ([System.String]$n)
	{
		$this.Name = $n
	}
}