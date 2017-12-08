/**
 * SymbolTableActorItem
 */
public class SymbolTableActorItem extends SymbolTableActorItemBase{
    public SymbolTableActorItem(Actor actor, int offset) {
		super(actor, offset);
	}

	@Override
	public Register getBaseRegister() {
		return Register.GP;
	}
	
	@Override
	public boolean useMustBeComesAfterDef() {
		return true;
	}
}