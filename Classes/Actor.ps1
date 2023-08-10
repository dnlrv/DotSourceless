class Actor
{
	[System.String]$Name

	Actor () {}

	Actor([System.String]$n)
	{
		$this.Name = $n
	}
}