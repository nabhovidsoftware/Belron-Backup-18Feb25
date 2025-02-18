public class BLN_StockRebookQueuable implements Queueable {
    Id caseId;
    public BLN_StockRebookQueuable(Id caseIdInner) {
        caseId = caseIdInner;
    }
    
    public void execute(QueueableContext context) {
        BLN_StockReservationController.rebookStocksCallout(caseId);
        }
}